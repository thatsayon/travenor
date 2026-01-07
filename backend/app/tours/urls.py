from django.urls import path
from .views import (
    TourListView,
    TourDetailView,
    JoinTourView,
    ConfirmBookingInfoView,
    UpcomingToursView,
    PastToursView,
)

urlpatterns = [
    path("list/", TourListView.as_view(), name="tour-list"),
    path("detail/<slug:slug>/", TourDetailView.as_view(), name="tour-detail"),
    path("join/<slug:slug>/", JoinTourView.as_view(), name="join-tour"),
    path("confirm/<uuid:booking_id>/", ConfirmBookingInfoView.as_view(), name="confirm-booking"),
    path("upcoming/", UpcomingToursView.as_view(), name="Upcoming Tour"),
    path("past/", PastToursView.as_view(), name="Past Tour"),
]
