from django.urls import path
from .views import (
    TourListView,
    TourDetailView,
)

urlpatterns = [
    path("list/", TourListView.as_view(), name="tour-list"),
    path("detail/<slug:slug>/", TourDetailView.as_view(), name="tour-detail"),
]
