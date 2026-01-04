from rest_framework import generics, permissions, status
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.exceptions import AuthenticationFailed
from rest_framework_simplejwt.tokens import RefreshToken
from django.db import transaction
from django.utils.timezone import now
from django.contrib.auth import authenticate, get_user_model
from django.shortcuts import get_object_or_404

from app.common.enums import AuthProviderChoices
from app.accounts.services.google import verify_google_token
from app.accounts.utils import generate_otp, create_otp_token, decode_otp_token
from app.accounts.models import OTP
from app.accounts.tasks import send_confirmation_email_task, send_password_reset_email_task

from .serializers import (
    GoogleAuthSerializer,
    RegisterSerializer,
    LoginSerializer,
) 
from .tokens import get_tokens_for_user

User = get_user_model()


class RegisterView(generics.CreateAPIView):
    permission_classes = [permissions.AllowAny]
    serializer_class = RegisterSerializer

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        try:
            with transaction.atomic():
                user = serializer.save()

                otp = generate_otp()

                OTP.objects.create(
                    user=user,
                    otp=otp,
                    created_at=now()
                )

                send_confirmation_email_task.delay(
                    user.email,
                    user.full_name,
                    otp
                )

                verification_token = create_otp_token(user.id)

                return Response(
                    {
                        "success": True,
                        "message": "Registration successful. OTP sent to email.",
                        "user": {
                            "id": str(user.id),
                            "email": user.email,
                        },
                        "verificationToken": verification_token,
                    },
                    status=status.HTTP_201_CREATED
                )

        except Exception as e:
            return Response(
                {
                    "success": False,
                    "message": f"Registration failed: {str(e)}"
                },
                status=status.HTTP_400_BAD_REQUEST
            )


class LoginView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        serializer = LoginSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(
                {"success": False, "error": serializer.errors},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        user = authenticate(
            username=serializer.validated_data.get("email"),
            password=serializer.validated_data.get("password")
        )

        if not user:
            return Response(
                {"success": False, "error": "Invalid email or password."},
                status=status.HTTP_401_UNAUTHORIZED
            )

        if not user.is_active:
            return Response(
                {"success": False, "error": "Account is not active. Please verify your email."},
                status=status.HTTP_403_FORBIDDEN
            )

        tokens = get_tokens_for_user(user)

        return Response(
            {
                "success": True,
                "access": tokens["access"],
                "refresh": tokens["refresh"],
            },
            status=status.HTTP_200_OK,
        )


class LogoutView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        return Response(
            {"success": True, "message": "Logged out successfully."},
            status=status.HTTP_200_OK
        )


class VerifyTokenView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        otp_token = request.data.get("verificationToken")
        if not otp_token:
            return Response(
                {"success": False, "error": "No token found."},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        decoded = decode_otp_token(otp_token)
        if not decoded:
            return Response(
                {"success": False, "error": "Invalid or expired token."},
                status=status.HTTP_400_BAD_REQUEST
            )
        return Response(
            {"success": True, "message": "Valid token."},
            status=status.HTTP_200_OK
        )


class VerifyOTPView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        otp = request.data.get("otp")
        otp_token = request.data.get("verificationToken")

        if not otp_token or not otp:
            return Response(
                {"success": False, "error": "OTP and verification token are required."},
                status=status.HTTP_400_BAD_REQUEST
            )

        decoded = decode_otp_token(otp_token)
        if not decoded:
            return Response(
                {"success": False, "error": "Invalid or expired token."},
                status=status.HTTP_400_BAD_REQUEST
            )

        user_id = decoded.get("user_id")
        try:
            user = User._default_manager.get(id=user_id)
        except User.DoesNotExist:
            return Response(
                {"success": False, "error": "User not found."},
                status=status.HTTP_404_NOT_FOUND
            )

        otp_instance = user.otps.filter(otp=otp).first()
        if not otp_instance or not otp_instance.is_valid():
            return Response(
                {"success": False, "error": "Invalid or expired OTP."},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Activate the user and clear OTPs
        user.is_active = True
        user.otps.all().delete()
        user.save()

        tokens = get_tokens_for_user(user)

        return Response(
            {
                "success": True,
                "access": tokens["access"],
                "refresh": tokens["refresh"],
            },
            status=status.HTTP_200_OK
        )


class ForgetPasswordView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        email = request.data.get("email")
        if not email:
            return Response(
                {"success": False, "error": "Email is required."},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        user = get_object_or_404(User, email=email)

        otp = generate_otp()

        OTP.objects.create(
            user=user,
            otp=otp,
            created_at=now()
        )

        send_password_reset_email_task.delay(
            user.email,
            user.full_name,
            otp
        )

        pass_reset_token = create_otp_token(user.id)

        return Response(
            {
                "success": True,
                "message": "OTP sent successfully.",
                "user": {
                    "id": str(user.id),
                    "email": user.email
                },
                "passResetToken": pass_reset_token
            },
            status=status.HTTP_200_OK
        )


class ForgetPasswordOTPVerifyView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request): 
        otp = request.data.get("otp")
        reset_token = request.data.get("passResetToken")
        
        if not otp or not reset_token:
            return Response(
                {"success": False, "error": "OTP and reset token are required."},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        decoded = decode_otp_token(reset_token)
        if not decoded:
            return Response(
                {"success": False, "error": "Invalid or expired reset token."},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        user_id = decoded.get("user_id")
        user = get_object_or_404(User, id=user_id)

        otp_instance = user.otps.filter(otp=otp).first()
        if not otp_instance or not otp_instance.is_valid():
            return Response(
                {"success": False, "error": "Invalid or expired OTP."},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Generate a verified token indicating that the OTP step is complete
        verified_payload = {"user_id": str(user.id), "verified": True}
        verified_token = create_otp_token(verified_payload)
        
        # Delete the used OTP instance
        otp_instance.delete()
        
        return Response(
            {
                "success": True,
                "message": "OTP verified. You can now reset your password.",
                "passwordResetVerified": verified_token
            }, 
            status=status.HTTP_200_OK
        )


class ForgotPasswordSetView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        new_password = request.data.get("new_password")
        verified_token = request.data.get("passwordResetVerified")
        
        if not new_password or not verified_token:
            return Response(
                {"success": False, "error": "New password and verified token are required."},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        decoded = decode_otp_token(verified_token)
        if not decoded or not decoded.get("verified"):
            return Response(
                {"success": False, "error": "Invalid or expired verified token."},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        user_id = decoded.get("user_id")
        try:
            user = User.objects.get(id=user_id)
        except User.DoesNotExist:
            return Response(
                {"success": False, "error": "User not found."},
                status=status.HTTP_404_NOT_FOUND
            )
        
        user.set_password(new_password)
        user.save()
        
        return Response(
            {"success": True, "message": "Password reset successfully."},
            status=status.HTTP_200_OK
        )


class ResendRegistrationOTPView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        verification_token = request.data.get("verificationToken")
        if not verification_token:
            return Response(
                {"success": False, "error": "No verification token found."},
                status=status.HTTP_400_BAD_REQUEST
            )

        decoded = decode_otp_token(verification_token)
        if not decoded:
            return Response(
                {"success": False, "error": "Invalid or expired token."},
                status=status.HTTP_400_BAD_REQUEST
            )

        user_id = decoded.get("user_id")
        user = get_object_or_404(User, id=user_id)

        if user.is_active:
            return Response(
                {"success": False, "message": "User already verified."},
                status=status.HTTP_400_BAD_REQUEST
            )

        otp = generate_otp()
        OTP.objects.create(user=user, otp=otp, created_at=now())

        send_confirmation_email_task.delay(user.email, user.full_name, otp)

        return Response(
            {"success": True, "message": "OTP resent successfully to your email."},
            status=status.HTTP_200_OK
        )


class ResendForgetPasswordOTPView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        reset_token = request.data.get("passResetToken")
        if not reset_token:
            return Response(
                {"success": False, "error": "No reset token found."},
                status=status.HTTP_400_BAD_REQUEST
            )

        decoded = decode_otp_token(reset_token)
        if not decoded:
            return Response(
                {"success": False, "error": "Invalid or expired reset token."},
                status=status.HTTP_400_BAD_REQUEST
            )

        user_id = decoded.get("user_id")
        user = get_object_or_404(User, id=user_id)

        otp = generate_otp()
        OTP.objects.create(user=user, otp=otp, created_at=now())

        send_password_reset_email_task.delay(user.email, user.full_name, otp)

        return Response(
            {"success": True, "message": "Password reset OTP resent successfully to your email."},
            status=status.HTTP_200_OK
        )


class GoogleLoginAPIView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        serializer = GoogleAuthSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        token = serializer.validated_data["token"]
        data = verify_google_token(token)

        if not data:
            raise AuthenticationFailed("Invalid Google token")

        user, created = User.objects.get_or_create(
            email=data["email"],
            defaults={
                "username": data["email"].split("@")[0],
                "full_name": data["full_name"],
                "auth_provider": AuthProviderChoices.GOOGLE,
                "google_id": data["google_id"],
            },
        )

        if not created and user.google_id is None:
            user.google_id = data["google_id"]
            user.auth_provider = AuthProviderChoices.GOOGLE
            user.save(update_fields=["google_id", "auth_provider"])

        if created:
            user.set_unusable_password()
            user.save()

        tokens = get_tokens_for_user(user)

        return Response(tokens, status=status.HTTP_200_OK)
