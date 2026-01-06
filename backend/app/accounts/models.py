from django.db import models
from django.contrib.auth.base_user import BaseUserManager
from django.contrib.auth.models import AbstractBaseUser, PermissionsMixin
from django.utils.translation import gettext_lazy as _
from django.utils import timezone

from cloudinary.models import CloudinaryField

from app.common.models import BaseModel
from app.common.enums import (
    GenderChoices, 
    BloodGroupChoices, 
    AuthProviderChoices
)


class CustomAccountManager(BaseUserManager):
    def create_user(self, email, password=None, **extra_fields):
        if not email:
            raise ValueError(_("The email must be set"))

        email = self.normalize_email(email)
        user = self.model(email=email, **extra_fields)
        user.set_password(password)
        user.is_active = extra_fields.get("is_active", True)
        user.save(using=self._db)
        return user

    def create_superuser(self, email, password=None, **extra_fields):
        extra_fields.setdefault("is_staff", True)
        extra_fields.setdefault("is_superuser", True)
        extra_fields.setdefault("is_active", True)

        if extra_fields.get("is_staff") is not True:
            raise ValueError("Superuser must have is_staff=True")
        if extra_fields.get("is_superuser") is not True:
            raise ValueError("Superuser must have is_superuser=True")

        return self.create_user(email, password, **extra_fields)


class UserAccount(BaseModel, AbstractBaseUser, PermissionsMixin):
    email = models.EmailField(_("email address"), unique=True)
    username = models.CharField(_("username"), max_length=30, unique=True)

    full_name = models.CharField(_("full name"), max_length=50)

    mobile_number = models.CharField(max_length=20, blank=True, null=True, unique=True)
    date_of_birth = models.DateField(blank=True, null=True)

    blood_group = models.CharField(
        max_length=3,
        choices=BloodGroupChoices.choices,
        blank=True,
        null=True,
    )

    profile_pic = CloudinaryField(blank=True, null=True)

    gender = models.CharField(
        max_length=10,
        choices=GenderChoices.choices,
        blank=True,
        null=True,
    )

    present_address = models.TextField(blank=True, null=True)

    emergency_contact_number = models.CharField(
        max_length=20,
        blank=True,
        null=True
    )

    emergency_contact_relationship = models.CharField(
        max_length=50,
        blank=True,
        null=True
    )

    profile_updated_at = models.DateTimeField(blank=True, null=True)

    auth_provider = models.CharField(
        max_length=20,
        choices=AuthProviderChoices.choices,
        default=AuthProviderChoices.EMAIL,
    )

    google_id = models.CharField(
        max_length=255,
        blank=True,
        null=True,
        unique=True,
    )

    is_staff = models.BooleanField(default=False)
    is_active = models.BooleanField(default=True)
    is_banned = models.BooleanField(default=False)

    date_joined = models.DateTimeField(default=timezone.now)

    USERNAME_FIELD = "email"
    REQUIRED_FIELDS = ["username"]

    objects = CustomAccountManager()

    def __str__(self):
        return self.email


class OTP(BaseModel):
    user = models.ForeignKey(UserAccount, on_delete=models.CASCADE, related_name="otps")
    otp = models.CharField(max_length=6)
    created_at = models.DateTimeField(auto_now_add=True)

    def is_valid(self, expiry_minutes=5):
        """Check if OTP is still valid (not expired)."""
        from datetime import timedelta
        expiry_time = self.created_at + timedelta(minutes=expiry_minutes)
        return timezone.now() <= expiry_time

    def __str__(self):
        return f"{self.user.email} - {self.otp}"

