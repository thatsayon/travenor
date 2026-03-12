from rest_framework import serializers
from django.utils.timezone import now
from django.contrib.auth import get_user_model

from app.accounts.models import UserProfile

User = get_user_model()


class ProfileSerializer(serializers.ModelSerializer):
    # UserAccount fields
    email = serializers.EmailField(source="user.email", read_only=True)
    full_name = serializers.CharField(source="user.full_name", read_only=True)
    username = serializers.CharField(source="user.username", read_only=True)

    profile_pic = serializers.SerializerMethodField()

    class Meta:
        model = UserProfile
        fields = (
            "email",
            "username",
            "full_name",
            "gender",
            "date_of_birth",
            "blood_group",
            "present_address",
            "mobile_number",
            "emergency_contact_number",
            "emergency_contact_relationship",
            "profile_pic",
        )

    def get_profile_pic(self, obj):
        if obj.profile_pic:
            return obj.profile_pic.url
        return None


class EditProfileSerializer(serializers.ModelSerializer):
    # Allow editing full_name on the UserAccount directly
    full_name = serializers.CharField(required=False)

    class Meta:
        model = UserProfile
        fields = (
            "profile_pic",
            "full_name",
            "gender",
            "date_of_birth",
            "blood_group",
            "present_address",
            "mobile_number",
            "emergency_contact_number",
            "emergency_contact_relationship",
        )

    def update(self, instance, validated_data):
        # Pop full_name and save it on the related UserAccount
        full_name = validated_data.pop("full_name", None)
        if full_name is not None:
            instance.user.full_name = full_name
            instance.user.save(update_fields=["full_name"])

        for attr, value in validated_data.items():
            setattr(instance, attr, value)

        instance.profile_updated_at = now()
        instance.save()
        return instance

