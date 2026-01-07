from django.core.validators import MinValueValidator, MaxValueValidator
from django.db import models
from django.conf import settings

from app.common.models import BaseModel

User = settings.AUTH_USER_MODEL

class Transport(BaseModel):
    name = models.CharField(max_length=100)
    icon = models.CharField(max_length=50, blank=True)  
    is_active = models.BooleanField(default=True)

    def __str__(self):
        return self.name


class TransportReview(BaseModel):
    transport = models.ForeignKey(
        Transport,
        on_delete=models.CASCADE,
        related_name="reviews"
    )
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    rating = models.PositiveSmallIntegerField(
        validators=[MinValueValidator(1), MaxValueValidator(5)]
    )

    class Meta:
        unique_together = ("transport", "user")


class Stay(BaseModel):
    name = models.CharField(max_length=150)
    icon = models.CharField(max_length=50, blank=True)  
    is_active = models.BooleanField(default=True)

    def __str__(self):
        return self.name


class StayReview(BaseModel):
    stay = models.ForeignKey(
        Stay,
        on_delete=models.CASCADE,
        related_name="reviews"
    )
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    rating = models.PositiveSmallIntegerField(
        validators=[MinValueValidator(1), MaxValueValidator(5)]
    )

    class Meta:
        unique_together = ("stay", "user")

