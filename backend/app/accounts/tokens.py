from rest_framework_simplejwt.tokens import RefreshToken

def get_tokens_for_user(user):
    refresh = RefreshToken.for_user(user)

    # 🔥 Custom claims (ACCESS token)
    refresh["user_id"] = str(user.id)
    refresh["email"] = user.email
    refresh["full_name"] = getattr(user, "full_name", "")
    refresh["username"] = user.username
    refresh["profile_pic"] = user.profile_pic
    refresh["auth_provider"] = user.auth_provider


    return {
        "access": str(refresh.access_token),
        "refresh": str(refresh),
    }

