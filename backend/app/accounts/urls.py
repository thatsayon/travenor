from django.urls import path

from .views import (
    LoginView,
    GoogleLoginAPIView,
)

urlpatterns = [
    path('login/', LoginView.as_view(), name='Login'),
    path('google/', GoogleLoginAPIView.as_view(), name='Google Login'),
]
