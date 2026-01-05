from rest_framework import serializers
from django.contrib.auth import get_user_model, password_validation
from django.utils.text import slugify
import uuid

User = get_user_model()


class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)
    email = serializers.EmailField()  # Override to remove unique validator

    class Meta:
        model = User
        fields = ("email", "password", "full_name")
        extra_kwargs = {
            'email': {'validators': []},  # Remove default unique validator
        }

    def validate_email(self, value):
        """
        Check if email exists. If user is inactive (unverified), 
        delete them to allow re-registration.
        """
        try:
            existing_user = User.objects.get(email=value)
            if not existing_user.is_active:
                # User exists but is not verified - delete to allow re-registration
                existing_user.otps.all().delete()
                existing_user.delete()
            else:
                # User exists and is active - raise error
                raise serializers.ValidationError("An account with this email already exists.")
        except User.DoesNotExist:
            pass
        return value

    def validate_password(self, value):
        password_validation.validate_password(value)
        return value

    def generate_username(self, full_name: str) -> str:
        first_name = (full_name.split()[0] if full_name else "user").lower()
        base_username = slugify(first_name) or "user"
        return f"{base_username}{uuid.uuid4().hex[:8]}"

    def create(self, validated_data):
        email = validated_data.get("email")
        full_name = validated_data.get("full_name", "").strip()
        password = validated_data.get("password")

        username = self.generate_username(full_name)

        user = User.objects.create_user(
            email=email,
            username=username,
            full_name=full_name,
            password=password,
            is_active=False,
        )
        return user


class GoogleAuthSerializer(serializers.Serializer):
    token = serializers.CharField()


class LoginSerializer(serializers.Serializer):
    email = serializers.EmailField()
    password = serializers.CharField(write_only=True)
