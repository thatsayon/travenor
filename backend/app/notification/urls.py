from django.urls import path
from .views import (
    NotificationPreferenceView,
)

urlpatterns = [
    path('preference/', NotificationPreferenceView.as_view(), name='Notification Preference'),
]
