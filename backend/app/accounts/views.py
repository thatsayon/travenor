from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.exceptions import AuthenticationFailed
from rest_framework import permissions, status
from rest_framework_simplejwt.tokens import RefreshToken

from django.contrib.auth import get_user_model

from app.common.enums import AuthProviderChoices
from app.accounts.services.google import verify_google_token

from .serializers import (
    GoogleAuthSerializer,
) 

User = get_user_model()

class LoginView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        return Response({
            "msg": "working"
        }, status=status.HTTP_200_OK)


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

        refresh = RefreshToken.for_user(user)

        return Response({
            "access": str(refresh.access_token),
            "refresh": str(refresh)
        })
