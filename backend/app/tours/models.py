from django.core.validators import MinValueValidator, MaxValueValidator
from django.contrib.auth import get_user_model
from django.db import models

from cloudinary.models import CloudinaryField

from app.guides.models import TourGuide
from app.common.models import BaseModel

from app.tours.location.models import *

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
    # Duration
    duration_days = models.IntegerField(validators=[MinValueValidator(1)])
    duration_nights = models.IntegerField(validators=[MinValueValidator(0)])

    # Pricing
    total_cost = models.DecimalField(max_digits=10, decimal_places=2)
    upfront_payment = models.DecimalField(max_digits=10, decimal_places=2)

    # Capacity
    min_group_size = models.IntegerField(default=12)
    max_capacity = models.IntegerField(default=16)

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


class TourBooking(BaseModel):
    tour = models.ForeignKey(
        Tour,
        on_delete=models.CASCADE,
        related_name="bookings"
    )
    user = models.ForeignKey(
        User,
        on_delete=models.CASCADE
    )
    seats = models.PositiveIntegerField(default=1)

    class Meta:
        unique_together = ("tour", "user")
