from rest_framework import serializers
from .models import (
    NotificationPreference,
)


class NotificationPreferenceSerializer(serializers.ModelSerializer):
    class Meta:
        model = NotificationPreference
        fields = (
            "new_tour_notifications",
            "booking_updates",
            "tour_reminders",
            "marketing_emails",
            "marketing_notifications",
        )

