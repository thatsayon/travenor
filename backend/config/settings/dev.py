from .base import *

DEBUG = True

ALLOWED_HOSTS = ["*"]

# Allow Cloudflare tunnel and local requests
CORS_ALLOWED_ORIGINS = [
    "https://travenor.projectyard.top",
    "http://localhost:3000",
    "http://127.0.0.1:3000",
    "https://travenor-v1.thatsayon.com",
]

CSRF_TRUSTED_ORIGINS = [
    "https://travenor.projectyard.top",
    "http://localhost:3000",
    "https://travenor-v1.thatsayon.com",
]

# Use SQLite for local development
# DATABASES = {
#     "default": {
#         "ENGINE": "django.db.backends.sqlite3",
#         "NAME": BASE_DIR / "db.sqlite3",
#     }
# }

EMAIL_BACKEND = "django.core.mail.backends.console.EmailBackend"
