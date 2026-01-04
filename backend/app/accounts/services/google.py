from google.oauth2 import id_token
from google.auth.transport import requests
from django.conf import settings


def verify_google_token(token: str):
    try:
        idinfo = id_token.verify_oauth2_token(
            token,
            requests.Request(),
            settings.GOOGLE_CLIENT_ID,
            # "726287101564-5psur8st5s5rp95q08q4el74q2n1jml2.apps.googleusercontent.com"
        )

        if idinfo["iss"] not in [
            "accounts.google.com",
            "https://accounts.google.com",
        ]:
            raise ValueError("Invalid issuer")

        return {
            "email": idinfo["email"],
            "full_name": idinfo.get("name", ""),
            "google_id": idinfo["sub"],
            "picture": idinfo.get("picture"),
            "email_verified": idinfo.get("email_verified", False),
        }

    except Exception:
        return None

