# Generated manually on 2026-03-12

import cloudinary.models
import django.db.models.deletion
import uuid
from django.conf import settings
from django.db import migrations, models


def migrate_profile_data_forward(apps, schema_editor):
    """Copy profile fields from UserAccount into new UserProfile rows."""
    UserAccount = apps.get_model("accounts", "UserAccount")
    UserProfile = apps.get_model("accounts", "UserProfile")

    for user in UserAccount.objects.all():
        UserProfile.objects.get_or_create(
            user=user,
            defaults={
                "profile_pic": user.profile_pic,
                "mobile_number": user.mobile_number,
                "date_of_birth": user.date_of_birth,
                "blood_group": user.blood_group,
                "gender": user.gender,
                "present_address": user.present_address,
                "emergency_contact_number": user.emergency_contact_number,
                "emergency_contact_relationship": user.emergency_contact_relationship,
                "profile_updated_at": user.profile_updated_at,
            },
        )


def migrate_profile_data_backward(apps, schema_editor):
    """Copy profile fields back from UserProfile into UserAccount."""
    UserProfile = apps.get_model("accounts", "UserProfile")

    for profile in UserProfile.objects.select_related("user").all():
        user = profile.user
        user.profile_pic = profile.profile_pic
        user.mobile_number = profile.mobile_number
        user.date_of_birth = profile.date_of_birth
        user.blood_group = profile.blood_group
        user.gender = profile.gender
        user.present_address = profile.present_address
        user.emergency_contact_number = profile.emergency_contact_number
        user.emergency_contact_relationship = profile.emergency_contact_relationship
        user.profile_updated_at = profile.profile_updated_at
        user.save()


class Migration(migrations.Migration):

    dependencies = [
        ("accounts", "0005_useraccount_emergency_contact_number_and_more"),
    ]

    operations = [
        # Step 1 – Create the UserProfile table (while UserAccount still has all fields)
        migrations.CreateModel(
            name="UserProfile",
            fields=[
                ("id", models.UUIDField(default=uuid.uuid4, editable=False, primary_key=True, serialize=False)),
                ("created_at", models.DateTimeField(auto_now_add=True)),
                ("updated_at", models.DateTimeField(auto_now=True)),
                (
                    "user",
                    models.OneToOneField(
                        on_delete=django.db.models.deletion.CASCADE,
                        related_name="profile",
                        to=settings.AUTH_USER_MODEL,
                    ),
                ),
                ("profile_pic", cloudinary.models.CloudinaryField(blank=True, max_length=255, null=True, verbose_name="image")),
                ("mobile_number", models.CharField(blank=True, max_length=20, null=True, unique=True)),
                ("date_of_birth", models.DateField(blank=True, null=True)),
                (
                    "blood_group",
                    models.CharField(
                        blank=True,
                        choices=[("A+", "A+"), ("A-", "A-"), ("B+", "B+"), ("B-", "B-"), ("AB+", "AB+"), ("AB-", "AB-"), ("O+", "O+"), ("O-", "O-")],
                        max_length=3,
                        null=True,
                    ),
                ),
                (
                    "gender",
                    models.CharField(
                        blank=True,
                        choices=[("male", "Male"), ("female", "Female")],
                        max_length=10,
                        null=True,
                    ),
                ),
                ("present_address", models.TextField(blank=True, null=True)),
                ("emergency_contact_number", models.CharField(blank=True, max_length=20, null=True)),
                ("emergency_contact_relationship", models.CharField(blank=True, max_length=50, null=True)),
                ("profile_updated_at", models.DateTimeField(blank=True, null=True)),
            ],
            options={
                "abstract": False,
            },
        ),
        # Step 2 – Copy existing data from UserAccount into UserProfile
        migrations.RunPython(
            migrate_profile_data_forward,
            reverse_code=migrate_profile_data_backward,
        ),
        # Step 3 – Remove profile fields from UserAccount
        migrations.RemoveField(model_name="useraccount", name="profile_pic"),
        migrations.RemoveField(model_name="useraccount", name="mobile_number"),
        migrations.RemoveField(model_name="useraccount", name="date_of_birth"),
        migrations.RemoveField(model_name="useraccount", name="blood_group"),
        migrations.RemoveField(model_name="useraccount", name="gender"),
        migrations.RemoveField(model_name="useraccount", name="present_address"),
        migrations.RemoveField(model_name="useraccount", name="emergency_contact_number"),
        migrations.RemoveField(model_name="useraccount", name="emergency_contact_relationship"),
        migrations.RemoveField(model_name="useraccount", name="profile_updated_at"),
    ]
