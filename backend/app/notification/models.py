from django.db import models
from django.conf import settings
from app.common.models import BaseModel

User = settings.AUTH_USER_MODEL


class NotificationPreference(BaseModel):
    user = models.OneToOneField(
        User,
        on_delete=models.CASCADE,
        related_name="notification_preferences"
    )

    # TOUR UPDATES
    new_tour_notifications = models.BooleanField(default=True)
    booking_updates = models.BooleanField(default=True)
    tour_reminders = models.BooleanField(default=True)

    # MARKETING
    marketing_emails = models.BooleanField(default=False)
    marketing_notifications = models.BooleanField(default=False)

    def __str__(self):
        return f"NotificationPreferences({self.user})"

