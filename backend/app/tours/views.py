from rest_framework import generics, permissions

from django.db.models import Count, Sum

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
            .select_related("tour_lead")
            .annotate(
                joined_count=Sum("bookings__seats")
            )
            .order_by("-created_at")
        )

class TourDetailView(generics.RetrieveAPIView):
    queryset = Tour.objects.filter(is_active=True).select_related("tour_lead")
    serializer_class = TourDetailSerializer
    permission_classes = [permissions.AllowAny]
    lookup_field = "slug"

