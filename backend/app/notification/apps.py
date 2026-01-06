from django.apps import AppConfig


class NotificationConfig(AppConfig):
    name = 'app.notification'

    def ready(self):
        import app.notification.signals
