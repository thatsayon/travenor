from django.db import models
from django.contrib.auth import get_user_model

from app.common.models import BaseModel

User = get_user_model()

class TourGuide(BaseModel):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    rating = models.DecimalField(max_digits=3, decimal_places=2, default=0.0)
