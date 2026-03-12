from django.contrib import admin
from .models import (
    UserAccount,
    UserProfile,
    OTP,
)


class UserProfileInline(admin.StackedInline):
    model = UserProfile
    can_delete = False
    verbose_name_plural = "Profile"


@admin.register(UserAccount)
class UserAccountAdmin(admin.ModelAdmin):
    inlines = [UserProfileInline]
    list_display = ("email", "username", "full_name", "is_active", "is_staff", "date_joined")
    search_fields = ("email", "username", "full_name")
    list_filter = ("is_active", "is_staff", "is_banned", "auth_provider")


@admin.register(UserProfile)
class UserProfileAdmin(admin.ModelAdmin):
    list_display = ("user", "mobile_number", "gender", "blood_group", "updated_at")
    search_fields = ("user__email", "user__username", "mobile_number")


admin.site.register(OTP)
