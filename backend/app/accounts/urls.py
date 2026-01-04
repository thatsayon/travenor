from django.urls import path

from .views import (
    RegisterView,
    LoginView,
    LogoutView,
    VerifyTokenView,
    VerifyOTPView,
    ForgetPasswordView,
    ForgetPasswordOTPVerifyView,
    ForgotPasswordSetView,
    ResendRegistrationOTPView,
    ResendForgetPasswordOTPView,
    GoogleLoginAPIView,
)

urlpatterns = [
    path('register/', RegisterView.as_view(), name='register'),
    path('login/', LoginView.as_view(), name='login'),
    path('logout/', LogoutView.as_view(), name='logout'),
    path('verify-token/', VerifyTokenView.as_view(), name='verify-token'),
    path('verify-otp/', VerifyOTPView.as_view(), name='verify-otp'),
    path('forget-password/', ForgetPasswordView.as_view(), name='forget-password'),
    path('forget-password-otp-verify/', ForgetPasswordOTPVerifyView.as_view(), name='forget-password-otp-verify'),
    path('forgot-password-set/', ForgotPasswordSetView.as_view(), name='forgot-password-set'),
    path('resend-registration-otp/', ResendRegistrationOTPView.as_view(), name='resend-registration-otp'),
    path('resend-forget-password-otp/', ResendForgetPasswordOTPView.as_view(), name='resend-forget-password-otp'),
    path('google/', GoogleLoginAPIView.as_view(), name='google-login'),
]
