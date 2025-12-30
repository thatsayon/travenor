from django.db import models
from django.contrib.auth.base_user import BaseUserManager
from django.contrib.auth.models import AbstractBaseUser, PermissionsMixin
from django.utils.translation import gettext_lazy as _
from django.utils import timezone

from cloudinary.models import CloudinaryField

from app.common.models import BaseModel
from app.common.enums import GenderChoices


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
    profile_pic = CloudinaryField(_("profile picture"), blank=True, null=True)

    gender = models.CharField(
        _("gender"),
        max_length=10,
        choices=GenderChoices.choices,
        blank=True,
        null=True,
    )

    is_staff = models.BooleanField(default=False)
    is_active = models.BooleanField(default=True)
    is_banned = models.BooleanField(default=False)

    date_joined = models.DateTimeField(default=timezone.now)

    USERNAME_FIELD = "email"
    REQUIRED_FIELDS = ["username"]

    objects = CustomAccountManager()

    class Meta:
        verbose_name = _("User Account")
        verbose_name_plural = _("User Accounts")
        ordering = ["-date_joined"]

    def __str__(self):
        return f"{self.email}"
