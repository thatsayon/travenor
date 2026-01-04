from rest_framework import serializers

from django.utils.timezone import now

from .models import Tour


class TourListSerializer(serializers.ModelSerializer):
    duration_text = serializers.ReadOnlyField()
    spots_remaining = serializers.SerializerMethodField()
    featured_image = serializers.SerializerMethodField()
    location_text = serializers.SerializerMethodField()
    time_left = serializers.SerializerMethodField()

    joined_count = serializers.IntegerField(read_only=True)
    progress_percent = serializers.SerializerMethodField()

    rating = serializers.DecimalField(
        source="rating_avg",
        max_digits=3,
        decimal_places=2,
        read_only=True
    )
    rating_count = serializers.IntegerField(read_only=True)

    class Meta:
        model = Tour
        fields = [
            "id",
            "title",
            "slug",
            "featured_image",
            "time_left",
            "location_text",
            "duration_text",

            "joined_count",
            "spots_remaining",
            "progress_percent",
            "min_group_size",
            "max_capacity",

            "upfront_payment",
            "total_cost",


            "rating",
            "rating_count",

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
    
    def get_time_left(self, obj):
        if not obj.booking_deadline:
            return None

        delta = obj.booking_deadline - now()

        if delta.total_seconds() <= 0:
            return None

        return {
            "days": delta.days,
            "hours": delta.seconds // 3600,
        }

    def get_progress_percent(self, obj):
        joined = obj.joined_count or 0
        if obj.max_capacity == 0:
            return 0
        return int((joined / obj.max_capacity) * 100)



class TourDetailSerializer(serializers.ModelSerializer):
    duration_text = serializers.ReadOnlyField()
    featured_image = serializers.SerializerMethodField()
    location_text = serializers.SerializerMethodField()
    time_left = serializers.SerializerMethodField()

    joined_count = serializers.IntegerField(read_only=True)
    spots_remaining = serializers.SerializerMethodField()
    progress_percent = serializers.SerializerMethodField()

    rating = serializers.DecimalField(
        source="rating_avg",
        max_digits=3,
        decimal_places=2,
        read_only=True
    )
    rating_count = serializers.IntegerField(read_only=True)

    tour_lead = serializers.StringRelatedField()

    class Meta:
        model = Tour
        fields = [
            "id",
            "title",
            "slug",
            "featured_image",

            # location & timing
            "location_text",
            "start_datetime",
            "booking_deadline",
            "time_left",

            # duration
            "duration_days",
            "duration_nights",
            "duration_text",

            # capacity
            "joined_count",
            "min_group_size",
            "max_capacity",
            "spots_remaining",
            "progress_percent",

            # pricing
            "upfront_payment",
            "total_cost",

            # rating
            "rating",
            "rating_count",

            # meeting & guide
            "meeting_point",
            "meeting_time",
            "tour_lead",

            # meta
            "is_active",
            "created_at",
            "updated_at",
        ]

    def get_featured_image(self, obj):
        return obj.featured_image.url if obj.featured_image else None

    def get_location_text(self, obj):
        parts = [obj.division.name]
        if obj.district:
            parts.append(obj.district.name)
        if obj.upazila:
            parts.append(obj.upazila.name)
        return ", ".join(parts)

    def get_spots_remaining(self, obj):
        joined = obj.joined_count or 0
        return max(obj.max_capacity - joined, 0)

    def get_progress_percent(self, obj):
        joined = obj.joined_count or 0
        if obj.max_capacity == 0:
            return 0
        return int((joined / obj.max_capacity) * 100)

    def get_time_left(self, obj):
        if not obj.booking_deadline:
            return None

        delta = obj.booking_deadline - now()
        if delta.total_seconds() <= 0:
            return None

        return {
            "days": delta.days,
            "hours": delta.seconds // 3600,
        }
