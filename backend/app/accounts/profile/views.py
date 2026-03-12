from rest_framework.views import APIView
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status

from app.accounts.models import UserProfile

from .serializers import (
    ProfileSerializer,
    EditProfileSerializer,
)


class ProfileView(APIView):
    permission_classes = [IsAuthenticated]

    def _get_or_create_profile(self, user):
        profile, _ = UserProfile.objects.get_or_create(user=user)
        return profile

    def get(self, request):
        profile = self._get_or_create_profile(request.user)
        serializer = ProfileSerializer(profile)
        return Response(
            {
                "success": True,
                "user": serializer.data
            },
            status=status.HTTP_200_OK
        )

    def patch(self, request):
        profile = self._get_or_create_profile(request.user)
        serializer = EditProfileSerializer(
            profile,
            data=request.data,
            partial=True
        )

        if not serializer.is_valid():
            first_error = next(iter(serializer.errors.values()))[0]
            return Response(
                {"error": first_error},
                status=status.HTTP_400_BAD_REQUEST
            )

        serializer.save()

        return Response(
            {
                "success": True,
                "message": "Profile updated successfully"
            },
            status=status.HTTP_200_OK
        )

