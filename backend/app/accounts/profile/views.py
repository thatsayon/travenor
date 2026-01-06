from rest_framework.views import APIView
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status

from .serializers import (
    ProfileSerializer,
    EditProfileSerializer,
)

class ProfileView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        serializer = ProfileSerializer(request.user)
        return Response(
            {
                "success": True,
                "user": serializer.data
            },
            status=status.HTTP_200_OK
        )

    def patch(self, request):
        serializer = EditProfileSerializer(
            request.user,
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

