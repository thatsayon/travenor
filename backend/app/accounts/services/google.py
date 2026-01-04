from google.oauth2 import id_token
from google.auth.transport import requests
from django.conf import settings


def verify_google_token(token: str):
    """
    Verify Google OAuth2 token against both web and Android client IDs.
    This allows tokens from both platforms to be accepted.
    """
    # Build list of client IDs to try (Android first if available, then web)
    client_ids = []
    android_client_id = getattr(settings, 'GOOGLE_ANDROID_CLIENT_ID', None)
    if android_client_id:
        client_ids.append(android_client_id)
    client_ids.append(settings.GOOGLE_CLIENT_ID) 
    
    if not client_ids:
        return None
    
    # Try verifying with each client ID
    idinfo = None
    for client_id in client_ids:
        try:
            idinfo = id_token.verify_oauth2_token(
                token,
                requests.Request(),
                client_id,
            )
            # If verification succeeds, break out of loop
            break
        except ValueError:
            # If this client ID fails, try the next one
            continue
    
    if idinfo is None:
        # If all client IDs fail, return None
        return None

    try:
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

