from django.contrib import admin
import nested_admin

from app.tours.location.models import Division, District, Upazila
from app.tours.feedback.models import Transport, Stay
from .models import (
    Tour, 
    TourDay, 
    TourDayActivity, 
    TourReview, 
    TourInclusion,
    TourBooking,
)

admin.site.register(TourBooking)


@admin.register(Division)
class DivisionAdmin(admin.ModelAdmin):
    list_display = ("name",)


@admin.register(District)
class DistrictAdmin(admin.ModelAdmin):
    list_display = ("name", "division")
    list_filter = ("division",)


@admin.register(Upazila)
class UpazilaAdmin(admin.ModelAdmin):
    list_display = ("name", "district")
    list_filter = ("district",)

@admin.register(Transport)
class TransportAdmin(admin.ModelAdmin):
    list_display = ("name", "is_active")
    list_filter = ("is_active",)

@admin.register(Stay)
class StayAdmin(admin.ModelAdmin):
    list_display = ("name", "is_active")
    list_filter = ("is_active",)

class TourDayActivityInline(nested_admin.NestedTabularInline):
    model = TourDayActivity
    extra = 1
    fields = ("title", "is_included", "order")


class TourDayInline(nested_admin.NestedStackedInline):
    model = TourDay
    extra = 1
    fields = ("day_number", "title", "subtitle")
    inlines = [TourDayActivityInline]

class TourInclusionInline(nested_admin.NestedTabularInline):
    model = TourInclusion
    extra = 1
    fields = ("title", "is_included", "order")


@admin.register(Tour)
class TourAdmin(nested_admin.NestedModelAdmin):
    list_display = ("title", "start_datetime", "is_active")
    list_filter = ("is_active", "division", "transport", "stay")
    search_fields = ("title",)
    prepopulated_fields = {"slug": ("title",)}

    inlines = [
        TourDayInline,
        TourInclusionInline,
    ]

    fieldsets = (
        ("Basic Info", {
            "fields": ("title", "slug", "featured_image", "is_active")
        }),
        ("Location", {
            "fields": ("division", "district", "upazila")
        }),
        ("Logistics", {
            "fields": ("transport", "stay")
        }),
        ("Schedule", {
            "fields": ("start_datetime", "booking_deadline")
        }),
        ("Duration", {
            "fields": ("duration_days", "duration_nights")
        }),
        ("Pricing", {
            "fields": ("total_cost", "upfront_payment")
        }),
        ("Capacity", {
            "fields": ("min_group_size", "max_capacity")
        }),
        ("Meeting Details", {
            "fields": ("meeting_point", "meeting_time", "tour_lead")
        }),
    )

