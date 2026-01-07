from django.core.validators import MinValueValidator, MaxValueValidator
from django.contrib.auth import get_user_model
from django.db import models

from cloudinary.models import CloudinaryField

from app.guides.models import TourGuide
from app.common.models import BaseModel

from app.tours.location.models import *
from app.tours.feedback.models import *

import uuid

User = get_user_model()

class Tour(BaseModel):
    title = models.CharField(max_length=200)
    slug = models.SlugField(unique=True)
    featured_image = CloudinaryField(blank=True, null=True)

    # Location (hierarchical)
    division = models.ForeignKey(
        Division,
        on_delete=models.PROTECT,
        related_name="tours"
    )
    district = models.ForeignKey(
        District,
        on_delete=models.PROTECT,
        null=True,
        blank=True,
        related_name="tours"
    )
    upazila = models.ForeignKey(
        Upazila,
        on_delete=models.PROTECT,
        null=True,
        blank=True,
        related_name="tours"
    )

    transport = models.ForeignKey(
        Transport,
        on_delete=models.PROTECT,
        related_name="tours"
    )
    stay = models.ForeignKey(
        Stay,
        on_delete=models.PROTECT,
        related_name="tours"
    )

    # Duration
    duration_days = models.IntegerField(validators=[MinValueValidator(1)])
    duration_nights = models.IntegerField(validators=[MinValueValidator(0)])

    # Pricing
    total_cost = models.DecimalField(max_digits=10, decimal_places=2)
    upfront_payment = models.DecimalField(max_digits=10, decimal_places=2)

    # Capacity
    min_group_size = models.IntegerField(default=12)
    max_capacity = models.IntegerField(default=16)

    start_datetime = models.DateTimeField(
        help_text="When the tour starts"
    )

    booking_deadline = models.DateTimeField(
        help_text="Last time users can book this tour"
    )

    # Meeting details
    meeting_point = models.CharField(max_length=200)
    meeting_time = models.TimeField()

    # Tour guide
    tour_lead = models.ForeignKey(TourGuide, on_delete=models.SET_NULL, null=True, related_name='tours')

    # Status
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        ordering = ['-created_at']
    
    def __str__(self):
        return self.title
    
    @property
    def duration_text(self):
        return f"{self.duration_days} Days, {self.duration_nights} Nights"


    def clean(self):
        """
        Enforce valid location hierarchy:
        - Division is mandatory
        - District must belong to Division
        - Upazila must belong to District
        """
        if self.district and self.district.division_id != self.division_id:
            raise ValidationError("District does not belong to selected division.")

        if self.upazila:
            if not self.district:
                raise ValidationError("Upazila cannot be set without a district.")
            if self.upazila.district_id != self.district_id:
                raise ValidationError("Upazila does not belong to selected district.")

    
    def get_reference_prefix(self):
        """
        Generates a 3-letter prefix from the tour title.
        Example: 'Sundarbans Explorer' -> 'SUN'
        """
        words = self.title.upper().split()

        if len(words) == 1:
            return words[0][:3]

        return "".join(word[0] for word in words[:3])


class TourDay(BaseModel):
    tour = models.ForeignKey(
        Tour,
        on_delete=models.CASCADE,
        related_name="days"
    )

    day_number = models.PositiveIntegerField()
    title = models.CharField(max_length=200)
    subtitle = models.CharField(
        max_length=255,
        blank=True,
        help_text="Short description under title"
    )

    class Meta:
        unique_together = ("tour", "day_number")
        ordering = ["day_number"]

    def __str__(self):
        return f"Day {self.day_number}: {self.title}"


class TourDayActivity(BaseModel):
    day = models.ForeignKey(
        TourDay,
        on_delete=models.CASCADE,
        related_name="activities"
    )

    title = models.CharField(max_length=200)
    is_included = models.BooleanField(default=True)

    order = models.PositiveIntegerField(default=0)

    class Meta:
        ordering = ["order"]

    def __str__(self):
        return self.title


class TourInclusion(BaseModel):
    tour = models.ForeignKey(
        Tour,
        on_delete=models.CASCADE,
        related_name="inclusions"
    )

    title = models.CharField(max_length=200)

    is_included = models.BooleanField(
        default=True,
        help_text="Checked = Included, Unchecked = Not Included"
    )

    order = models.PositiveIntegerField(default=0)

    class Meta:
        ordering = ("order",)

    def __str__(self):
        status = "Included" if self.is_included else "Not Included"
        return f"{status}: {self.title}"



class TourBooking(BaseModel):

    STATUS_CHOICES = (
        ("draft", "Draft"),
        ("pending", "Pending Approval"),
        ("paid", "Paid"),
        ("cancelled", "Cancelled"),
        ("refunded", "Refunded"),
    )

    tour = models.ForeignKey(
        Tour,
        on_delete=models.CASCADE,
        related_name="bookings"
    )
    user = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name="tour_bookings"
    )

    seats = models.PositiveIntegerField(default=1)

    status = models.CharField(
        max_length=20,
        choices=STATUS_CHOICES,
        default="draft"
    )

    booking_reference = models.CharField(
        max_length=20,
        unique=True,
        blank=True,
        null=True
    )

    accepted_terms_at = models.DateTimeField(null=True, blank=True)
    confirmed_at = models.DateTimeField(null=True, blank=True)
    paid_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        unique_together = ("tour", "user")

    def generate_reference(self):
        prefix = self.tour.get_reference_prefix()

        while True:
            unique_part = str(uuid.uuid4().int)[:6]
            ref = f"{prefix}-{unique_part}"

            if not TourBooking.objects.filter(booking_reference=ref).exists():
                return ref

    def __str__(self):
        return f"{self.booking_reference or 'NO-REF'} | {self.user.email}"

class TourReview(BaseModel):
    tour = models.ForeignKey(
        Tour,
        on_delete=models.CASCADE,
        related_name="reviews"
    )
    user = models.ForeignKey(
        User,
        on_delete=models.CASCADE
    )

    rating = models.PositiveSmallIntegerField(
        validators=[MinValueValidator(1), MaxValueValidator(5)]
    )
    comment = models.TextField(blank=True)

    class Meta:
        unique_together = ("tour", "user")

    def __str__(self):
        return f"{self.rating}⭐ - {self.tour.title}"
