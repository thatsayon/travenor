from django.utils.translation import gettext_lazy as _
from django.db import models

class GenderChoices(models.TextChoices):
    MALE = "male", _("Male")
    FEMALE = "female", _("Female")

