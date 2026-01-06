from rest_framework import serializers
from django.utils.timezone import now
from django.contrib.auth import get_user_model

User = get_user_model()

class ProfileSerializer(serializers.ModelSerializer):
    profile_pic = serializers.SerializerMethodField()

    class Meta:
        model = User
        fields = (
            "email",
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
    class Meta:
        model = User
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
        for attr, value in validated_data.items():
            setattr(instance, attr, value)

        instance.profile_updated_at = now()
        instance.save()
        return instance

