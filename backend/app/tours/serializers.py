from rest_framework import serializers

from django.utils.timezone import now
from django.db.models import Count

from app.guides.models import TourGuide

from .models import Tour, TourDayActivity, TourDay, TourInclusion, TourBooking


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


class TourDayActivitySerializer(serializers.ModelSerializer):
    class Meta:
        model = TourDayActivity
        fields = (
            "title",
            "is_included",
        )


class TourDaySerializer(serializers.ModelSerializer):
    activities = TourDayActivitySerializer(many=True, read_only=True)

    class Meta:
        model = TourDay
        fields = (
            "day_number",
            "title",
            "subtitle",
            "activities",
        )


class TourInclusionSerializer(serializers.ModelSerializer):
    class Meta:
        model = TourInclusion
        fields = (
            "title",
            "is_included",
        )

class TourGuideSerializer(serializers.ModelSerializer):
    full_name = serializers.CharField(source="user.full_name", read_only=True)
    profile_pic = serializers.SerializerMethodField()
    tours_completed = serializers.IntegerField(read_only=True)

    class Meta:
        model = TourGuide
        fields = (
            "id",
            "full_name",
            "profile_pic",
            "rating",
            "tours_completed",
        )

    def get_profile_pic(self, obj):
        return obj.user.profile_pic.url if obj.user.profile_pic else None

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

    tour_lead = serializers.SerializerMethodField()

    tour_plan = TourDaySerializer(
        source="days",
        many=True,
        read_only=True
    )

    included = serializers.SerializerMethodField()
    not_included = serializers.SerializerMethodField()

    transport = serializers.SerializerMethodField()
    stay = serializers.SerializerMethodField()


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

            #logistics
            "transport",
            "stay",

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

            "tour_plan",
            "included",
            "not_included",

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

    def get_included(self, obj):
        qs = obj.inclusions.filter(is_included=True)
        return TourInclusionSerializer(qs, many=True).data

    def get_not_included(self, obj):
        qs = obj.inclusions.filter(is_included=False)
        return TourInclusionSerializer(qs, many=True).data

    def get_transport(self, obj):
        return {
            "name": obj.transport.name,
            "rating": obj.transport_rating,
        }

    def get_stay(self, obj):
        return {
            "name": obj.stay.name,
            "rating": obj.stay_rating,
        }

    def get_tour_lead(self, obj):
        if not obj.tour_lead:
            return None

        guide = (
            obj.tour_lead.__class__.objects
            .filter(pk=obj.tour_lead.pk)
            .annotate(
                tours_completed=Count("tours", distinct=True)
            )
            .select_related("user")
            .first()
        )

        return TourGuideSerializer(guide).data



class JoinTourSerializer(serializers.Serializer):
    full_name = serializers.CharField(required=False)
    mobile_number = serializers.CharField(required=False)
    emergency_contact_number = serializers.CharField(required=False)
    emergency_contact_relationship = serializers.CharField(required=False)



class MyTourSerializer(serializers.ModelSerializer):
    tour_title = serializers.CharField(source="tour.title")
    tour_image = serializers.SerializerMethodField()
    start_date = serializers.DateTimeField(source="tour.start_datetime")
    location = serializers.SerializerMethodField()
    price = serializers.DecimalField(
        source="tour.upfront_payment",
        max_digits=10,
        decimal_places=2
    )

    class Meta:
        model = TourBooking
        fields = (
            "id",
            "tour_title",
            "tour_image",
            "start_date",
            "location",
            "status",
            "price",
            "booking_reference",
        )

    def get_tour_image(self, obj):
        if obj.tour.featured_image:
            return obj.tour.featured_image.url
        return None

    def get_location(self, obj):
        tour = obj.tour
        parts = [tour.division.name]

        if tour.district:
            parts.append(tour.district.name)
        if tour.upazila:
            parts.append(tour.upazila.name)

        return ", ".join(parts)
