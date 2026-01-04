from rest_framework import generics, permissions

from django.db.models import Count, Sum, Avg

from .models import Tour
from .serializers import (
    TourListSerializer,
    TourDetailSerializer,
)

class TourListView(generics.ListAPIView):
    permission_classes = [permissions.AllowAny]
    serializer_class = TourListSerializer

    def get_queryset(self):
        return (
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


class TourDetailView(generics.RetrieveAPIView):
    permission_classes = [permissions.AllowAny]
    serializer_class = TourDetailSerializer
    lookup_field = "slug"

    def get_queryset(self):
        return (
            Tour.objects
            .filter(is_active=True)
            .select_related(
                "tour_lead",
                "division",
                "district",
                "upazila",
            )
            .annotate(
                joined_count=Sum("bookings__seats"),
                rating_avg=Avg("reviews__rating"),
                rating_count=Count("reviews"),
            )
        )

