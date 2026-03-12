from rest_framework import generics, permissions
from rest_framework.views import APIView
from rest_framework.response import Response

from django.db.models import Count, Sum, Avg, Exists, OuterRef, Value, Subquery, IntegerField
from django.db.models.functions import Coalesce
from django.shortcuts import get_object_or_404
from django.utils import timezone

from .models import Tour, TourBooking
from .serializers import (
    TourListSerializer,
    TourDetailSerializer,
    JoinTourSerializer,
    MyTourSerializer,
)

import uuid

class TourListView(generics.ListAPIView):
    permission_classes = [permissions.AllowAny]
    serializer_class = TourListSerializer

    def get_queryset(self):
        qs = (
            Tour.objects
            .filter(is_active=True)
            .select_related(
                "division",
                "district",
                "upazila",
            )
            .annotate(
                joined_count=Sum("bookings__seats"),
                rating_avg=Avg("reviews__rating"),
                rating_count=Count("reviews"),
            )
            .order_by("-created_at")
        )

        if self.request.user.is_authenticated:
            qs = qs.annotate(
                is_booked=Exists(
                    TourBooking.objects.filter(
                        tour=OuterRef("pk"),
                        user=self.request.user,
                        status__in=("pending", "paid"),
                    )
                )
            )
        
        return qs


class TourDetailView(generics.RetrieveAPIView):
    permission_classes = [permissions.AllowAny]
    serializer_class = TourDetailSerializer
    lookup_field = "slug"

    def get_queryset(self):
        qs = (
            Tour.objects
            .filter(is_active=True)
            .select_related(
                "tour_lead__user",
                "division",
                "district",
                "upazila",
            )
            .annotate(
                joined_count=Sum("bookings__seats"),
                rating_avg=Avg("reviews__rating"),
                rating_count=Count("reviews", distinct=True),
                transport_rating=Avg("transport__reviews__rating"),
                stay_rating=Avg("stay__reviews__rating"),
            )
        )

        if self.request.user.is_authenticated:
            qs = qs.annotate(
                is_booked=Exists(
                    TourBooking.objects.filter(
                        tour=OuterRef("pk"),
                        user=self.request.user,
                        status__in=("pending", "paid"),
                    )
                )
            )

        return qs


class JoinTourView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, slug):
        tour = get_object_or_404(Tour, slug=slug, is_active=True)
        user = request.user

        missing = user.missing_booking_fields()

        try:
            profile = user.profile
        except Exception:
            from app.accounts.models import UserProfile
            profile, _ = UserProfile.objects.get_or_create(user=user)

        return Response({
            "tour": {
                "title": tour.title,
                "duration_text": tour.duration_text,
            },
            "user_data": {
                "full_name": user.full_name or "",
                "mobile_number": profile.mobile_number or "",
                "email": user.email,
                "emergency_contact_number": profile.emergency_contact_number or "",
                "emergency_contact_relationship": profile.emergency_contact_relationship or "",
            },
            "missing_fields": missing,
            "can_proceed": len(missing) == 0
        })

    def post(self, request, slug):
        tour = get_object_or_404(Tour, slug=slug, is_active=True)
        user = request.user

        if tour.booking_deadline < timezone.now():
            return Response({"detail": "Booking closed"}, status=400)

        serializer = JoinTourSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        from app.accounts.models import UserProfile
        profile, _ = UserProfile.objects.get_or_create(user=user)

        # Update full_name on the account if provided and missing
        if "full_name" in serializer.validated_data:
            user.full_name = serializer.validated_data["full_name"]
            user.save(update_fields=["full_name"])

        # Update profile fields
        profile_fields = [
            "mobile_number",
            "emergency_contact_number",
            "emergency_contact_relationship",
        ]
        profile_updated = False
        for field in profile_fields:
            if field in serializer.validated_data:
                setattr(profile, field, serializer.validated_data[field])
                profile_updated = True

        if profile_updated:
            profile.profile_updated_at = timezone.now()
            profile.save()

        # Get or create a draft booking — if one already exists (user went back),
        # reuse it rather than creating a duplicate.
        booking, created = TourBooking.objects.get_or_create(
            tour=tour,
            user=user,
            defaults={"status": "draft"}
        )

        # If the booking exists but was cancelled/refunded, reset it to draft
        if not created and booking.status in ("cancelled", "refunded"):
            booking.status = "draft"
            booking.booking_reference = None
            booking.accepted_terms_at = None
            booking.confirmed_at = None
            booking.save()

        return Response({
            "booking_id": booking.id,
            "next_step": "confirm"
        })


class ConfirmBookingInfoView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, booking_id):
        booking = get_object_or_404(
            TourBooking,
            id=booking_id,
            user=request.user
        )

        user = booking.user
        try:
            profile = user.profile
        except Exception:
            from app.accounts.models import UserProfile
            profile, _ = UserProfile.objects.get_or_create(user=user)

        return Response({
            "tour": {
                "title": booking.tour.title,
                "location": booking.tour.division.name,
                "duration_text": booking.tour.duration_text,
            },
            "user": {
                "full_name": user.full_name,
                "mobile_number": profile.mobile_number,
                "emergency_contact": (
                    f"{profile.emergency_contact_relationship} - "
                    f"{profile.emergency_contact_number}"
                )
            },
            "price_summary": {
                "package_price": booking.tour.upfront_payment,
                "total_amount": booking.tour.upfront_payment,
            }
        })

    def post(self, request, booking_id):
        booking = get_object_or_404(
            TourBooking,
            id=booking_id,
            user=request.user
        )

        if booking.status != "draft":
            return Response(
                {"detail": "Booking already submitted"},
                status=400
            )

        if not request.data.get("accepted_terms"):
            return Response(
                {"detail": "You must accept terms and refund policy"},
                status=400
            )

        # Generate booking reference ONCE
        if not booking.booking_reference:
            booking.booking_reference = booking.generate_reference()

        booking.status = "pending"
        booking.accepted_terms_at = timezone.now()
        booking.confirmed_at = timezone.now()
        booking.save()

        tour = booking.tour

        return Response({
            "booking_reference": booking.booking_reference,
            "status": booking.status,
            "tour": {
                "title": tour.title,
                "location": tour.division.name,
                "duration_text": tour.duration_text,
            },
            "message": "Booking request submitted"
        })


class UpcomingToursView(generics.ListAPIView):
    permission_classes = [permissions.IsAuthenticated]
    serializer_class = MyTourSerializer

    def get_queryset(self):
        tour_bookings_sum = TourBooking.objects.filter(
            tour=OuterRef('tour')
        ).values('tour').annotate(
            total_seats=Sum('seats')
        ).values('total_seats')

        return (
            TourBooking.objects
            .filter(
                user=self.request.user,
                status__in=["pending", "paid"],
                tour__start_datetime__gte=timezone.now(),
            )
            .select_related(
                "tour",
                "tour__division",
                "tour__district",
                "tour__upazila",
            )
            .annotate(
                tour_joined_count=Coalesce(Subquery(tour_bookings_sum, output_field=IntegerField()), 0)
            )
            .order_by("tour__start_datetime")
        )


class PastToursView(generics.ListAPIView):
    permission_classes = [permissions.IsAuthenticated]
    serializer_class = MyTourSerializer

    def get_queryset(self):
        return (
            TourBooking.objects
            .filter(
                user=self.request.user,
                tour__start_datetime__lt=timezone.now(),
            )
            .select_related(
                "tour",
                "tour__division",
                "tour__district",
                "tour__upazila",
            )
            .order_by("-tour__start_datetime")
        )

