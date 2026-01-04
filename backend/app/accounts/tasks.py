try:
    from celery import shared_task
except ImportError:
    def shared_task(func):
        def wrapper(*args, **kwargs):
            return func(*args, **kwargs)
        wrapper.delay = func
        return wrapper

from django.core.mail import send_mail
from django.conf import settings

@shared_task
def send_confirmation_email_task(email, full_name, otp):
    subject = "Verify your account"
    message = f"Hello {full_name},\n\nYour OTP for account verification is: {otp}\n\nThank you!"
    from_email = getattr(settings, "DEFAULT_FROM_EMAIL", "webmaster@localhost")
    
    send_mail(subject, message, from_email, [email], fail_silently=False)


@shared_task
def send_password_reset_email_task(email, full_name, otp):
    subject = "Password Reset OTP"
    message = f"Hello {full_name},\n\nYour OTP for password reset is: {otp}\n\nThis OTP will expire in 5 minutes.\n\nThank you!"
    from_email = getattr(settings, "DEFAULT_FROM_EMAIL", "webmaster@localhost")
    
    send_mail(subject, message, from_email, [email], fail_silently=False)

