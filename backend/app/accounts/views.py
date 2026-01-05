from rest_framework import generics, permissions, status
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.exceptions import AuthenticationFailed
from rest_framework_simplejwt.tokens import RefreshToken
from django.db import transaction
from django.utils.timezone import now
from django.contrib.auth import authenticate, get_user_model

from django.views.decorators.csrf import csrf_exempt
from django.utils.decorators import method_decorator
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



@method_decorator(csrf_exempt, name='dispatch')
class RegisterView(generics.CreateAPIView):
    permission_classes = [permissions.AllowAny]
    serializer_class = RegisterSerializer

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        
        if not serializer.is_valid():
            # Return first error message in standard format
            errors = serializer.errors
            first_error = None
            for field, messages in errors.items():
                if messages:
                    if field == 'non_field_errors':
                        first_error = messages[0] if isinstance(messages, list) else str(messages)
                    else:
                        first_error = messages[0] if isinstance(messages, list) else str(messages)
                    break
            return Response(
                {"error": first_error or "Invalid data."},
                status=status.HTTP_400_BAD_REQUEST
            )

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
                {"error": f"Registration failed: {str(e)}"},
                status=status.HTTP_400_BAD_REQUEST
            )


@method_decorator(csrf_exempt, name='dispatch')
class LoginView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        serializer = LoginSerializer(data=request.data)
        if not serializer.is_valid():
            errors = serializer.errors
            first_error = None
            for field, messages in errors.items():
                if messages:
                    first_error = messages[0] if isinstance(messages, list) else str(messages)
                    break
            return Response(
                {"error": first_error or "Invalid data."},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        user = authenticate(
            username=serializer.validated_data.get("email"),
            password=serializer.validated_data.get("password")
        )

        if not user:
            return Response(
                {"error": "Invalid email or password."},
                status=status.HTTP_401_UNAUTHORIZED
            )

        if not user.is_active:
            return Response(
                {"error": "Account is not active. Please verify your email."},
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



@method_decorator(csrf_exempt, name='dispatch')
class LogoutView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        return Response(
            {"success": True, "message": "Logged out successfully."},
            status=status.HTTP_200_OK
        )



@method_decorator(csrf_exempt, name='dispatch')
class VerifyTokenView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        otp_token = request.data.get("verificationToken")
        if not otp_token:
            return Response(
                {"error": "No token found."},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        decoded = decode_otp_token(otp_token)
        if not decoded:
            return Response(
                {"error": "Invalid or expired token."},
                status=status.HTTP_400_BAD_REQUEST
            )
        return Response(
            {"success": True, "message": "Valid token."},
            status=status.HTTP_200_OK
        )



@method_decorator(csrf_exempt, name='dispatch')
class VerifyOTPView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        otp = request.data.get("otp")
        otp_token = request.data.get("verificationToken")

        if not otp_token or not otp:
            return Response(
                {"error": "OTP and verification token are required."},
                status=status.HTTP_400_BAD_REQUEST
            )

        decoded = decode_otp_token(otp_token)
        if not decoded:
            return Response(
                {"error": "Invalid or expired token."},
                status=status.HTTP_400_BAD_REQUEST
            )

        user_id = decoded.get("user_id")
        try:
            user = User._default_manager.get(id=user_id)
        except User.DoesNotExist:
            return Response(
                {"error": "User not found."},
                status=status.HTTP_404_NOT_FOUND
            )

        otp_instance = user.otps.filter(otp=otp).first()
        if not otp_instance or not otp_instance.is_valid():
            return Response(
                {"error": "Invalid or expired OTP."},
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



@method_decorator(csrf_exempt, name='dispatch')
class ForgetPasswordView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        email = request.data.get("email")
        if not email:
            return Response(
                {"error": "Email is required."},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        try:
            user = User.objects.get(email=email)
        except User.DoesNotExist:
            return Response(
                {"error": "No account found with this email."},
                status=status.HTTP_404_NOT_FOUND
            )

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



@method_decorator(csrf_exempt, name='dispatch')
class ForgetPasswordOTPVerifyView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request): 
        otp = request.data.get("otp")
        reset_token = request.data.get("passResetToken")
        
        if not otp or not reset_token:
            return Response(
                {"error": "OTP and reset token are required."},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        decoded = decode_otp_token(reset_token)
        if not decoded:
            return Response(
                {"error": "Invalid or expired reset token."},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        user_id = decoded.get("user_id")
        try:
            user = User.objects.get(id=user_id)
        except User.DoesNotExist:
            return Response(
                {"error": "User not found."},
                status=status.HTTP_404_NOT_FOUND
            )

        otp_instance = user.otps.filter(otp=otp).first()
        if not otp_instance or not otp_instance.is_valid():
            return Response(
                {"error": "Invalid or expired OTP."},
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



@method_decorator(csrf_exempt, name='dispatch')
class ForgotPasswordSetView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        new_password = request.data.get("new_password")
        verified_token = request.data.get("passwordResetVerified")
        
        if not new_password or not verified_token:
            return Response(
                {"error": "New password and verified token are required."},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        decoded = decode_otp_token(verified_token)
        if not decoded or not decoded.get("verified"):
            return Response(
                {"error": "Invalid or expired verified token."},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        user_id = decoded.get("user_id")
        try:
            user = User.objects.get(id=user_id)
        except User.DoesNotExist:
            return Response(
                {"error": "User not found."},
                status=status.HTTP_404_NOT_FOUND
            )
        
        user.set_password(new_password)
        user.save()
        
        return Response(
            {"success": True, "message": "Password reset successfully."},
            status=status.HTTP_200_OK
        )



@method_decorator(csrf_exempt, name='dispatch')
class ResendRegistrationOTPView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        verification_token = request.data.get("verificationToken")
        if not verification_token:
            return Response(
                {"error": "No verification token found."},
                status=status.HTTP_400_BAD_REQUEST
            )

        decoded = decode_otp_token(verification_token)
        if not decoded:
            return Response(
                {"error": "Invalid or expired token."},
                status=status.HTTP_400_BAD_REQUEST
            )

        user_id = decoded.get("user_id")
        try:
            user = User.objects.get(id=user_id)
        except User.DoesNotExist:
            return Response(
                {"error": "User not found."},
                status=status.HTTP_404_NOT_FOUND
            )

        if user.is_active:
            return Response(
                {"error": "User already verified."},
                status=status.HTTP_400_BAD_REQUEST
            )

        otp = generate_otp()
        OTP.objects.create(user=user, otp=otp, created_at=now())

        send_confirmation_email_task.delay(user.email, user.full_name, otp)

        return Response(
            {"success": True, "message": "OTP resent successfully to your email."},
            status=status.HTTP_200_OK
        )



@method_decorator(csrf_exempt, name='dispatch')
class ResendForgetPasswordOTPView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        reset_token = request.data.get("passResetToken")
        if not reset_token:
            return Response(
                {"error": "No reset token found."},
                status=status.HTTP_400_BAD_REQUEST
            )

        decoded = decode_otp_token(reset_token)
        if not decoded:
            return Response(
                {"error": "Invalid or expired reset token."},
                status=status.HTTP_400_BAD_REQUEST
            )

        user_id = decoded.get("user_id")
        try:
            user = User.objects.get(id=user_id)
        except User.DoesNotExist:
            return Response(
                {"error": "User not found."},
                status=status.HTTP_404_NOT_FOUND
            )

        otp = generate_otp()
        OTP.objects.create(user=user, otp=otp, created_at=now())

        send_password_reset_email_task.delay(user.email, user.full_name, otp)

        return Response(
            {"success": True, "message": "Password reset OTP resent successfully to your email."},
            status=status.HTTP_200_OK
        )



@method_decorator(csrf_exempt, name='dispatch')
class GoogleLoginAPIView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        serializer = GoogleAuthSerializer(data=request.data)
        if not serializer.is_valid():
            errors = serializer.errors
            first_error = None
            for field, messages in errors.items():
                if messages:
                    first_error = messages[0] if isinstance(messages, list) else str(messages)
                    break
            return Response(
                {"error": first_error or "Invalid data."},
                status=status.HTTP_400_BAD_REQUEST
            )

        token = serializer.validated_data["token"]
        data = verify_google_token(token)

        if not data:
            return Response(
                {"error": "Invalid Google token."},
                status=status.HTTP_401_UNAUTHORIZED
            )

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

        return Response(
            {
                "success": True,
                "access": tokens["access"],
                "refresh": tokens["refresh"],
            },
            status=status.HTTP_200_OK
        )
