from rest_framework import serializers
from .models import Tour

# class TourListSerializer(serializers.ModelSerializer):
#     duration_text = serializers.ReadOnlyField()
#     spots_remaining = serializers.SerializerMethodField()
#     featured_image = serializers.SerializerMethodField()
#     rating = serializers.DecimalField(
#         source="tour_lead.rating",
#         max_digits=3,
#         decimal_places=2,
#         read_only=True
#     )
#
#     class Meta:
#         model = Tour
#         fields = [
#             "id",
#             "title",
#             "slug",
#             "featured_image",
#             "duration_text",
#             "rating",
#             "min_group_size",
#             "max_capacity",
#             "upfront_payment",
#             "total_cost",
#             "spots_remaining",
#         ]
#
#     def get_spots_remaining(self, obj):
#         joined = obj.joined_count or 0
#         return max(obj.max_capacity - joined, 0)
#
#     def get_featured_image(self, obj):
#         if obj.featured_image:
#             return obj.featured_image.url
#         return None

class TourListSerializer(serializers.ModelSerializer):
    duration_text = serializers.ReadOnlyField()
    spots_remaining = serializers.SerializerMethodField()
    featured_image = serializers.SerializerMethodField()
    location_text = serializers.SerializerMethodField()

    rating = serializers.DecimalField(
        source="tour_lead.rating",
        max_digits=3,
        decimal_places=2,
        read_only=True
    )

    class Meta:
        model = Tour
        fields = [
            "id",
            "title",
            "slug",
            "featured_image",
            "location_text",
            "duration_text",
            "rating",
            "min_group_size",
            "max_capacity",
            "upfront_payment",
            "total_cost",
            "spots_remaining",
        ]

    def get_spots_remaining(self, obj):
        joined = obj.joined_count or 0
        return max(obj.max_capacity - joined, 0)

    def get_featured_image(self, obj):
        if obj.featured_image:
            return obj.featured_image.url
        return None

    def get_location_text(self, obj):
        """
        Returns:
        - 'Khulna'
        - 'Khulna, Bagerhat'
        - 'Khulna, Bagerhat, Mongla'
        """
        parts = [obj.division.name]

        if obj.district:
            parts.append(obj.district.name)

        if obj.upazila:
            parts.append(obj.upazila.name)

        return ", ".join(parts)


class TourDetailSerializer(serializers.ModelSerializer):
    duration_text = serializers.ReadOnlyField()
    tour_lead = serializers.StringRelatedField()

    class Meta:
        model = Tour
        fields = [
            "id",
            "title",
            "slug",
            "featured_image",
            "duration_days",
            "duration_nights",
            "duration_text",
            "total_cost",
            "upfront_payment",
            "min_group_size",
            "max_capacity",
            "meeting_point",
            "meeting_time",
            "tour_lead",
            "is_active",
            "created_at",
            "updated_at",
        ]
