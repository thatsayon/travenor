from django.test import TestCase
from django.contrib.auth import get_user_model
from unittest.mock import patch, MagicMock
from app.accounts.serializers import RegisterSerializer
from app.accounts.models import OTP

User = get_user_model()


class RegisterSerializerTestCase(TestCase):
    @patch("app.accounts.views.send_confirmation_email_task.delay")
    def test_register_serializer_create(self, mock_send_email):
        data = {
            "email": "test@example.com",
            "password": "StrongPassword123!",
            "full_name": "Test User",
        }
        serializer = RegisterSerializer(data=data)
        self.assertTrue(serializer.is_valid())
        user = serializer.save()

        self.assertEqual(user.email, data["email"])
        self.assertEqual(user.full_name, data["full_name"])
        self.assertTrue(user.check_password(data["password"]))
        self.assertFalse(user.is_active)
        self.assertTrue(user.username.startswith("test"))

    def test_register_serializer_missing_fields(self):
        data = {
            "email": "test@example.com",
        }
        serializer = RegisterSerializer(data=data)
        self.assertFalse(serializer.is_valid())
        self.assertIn("password", serializer.errors)
        self.assertIn("full_name", serializer.errors)

