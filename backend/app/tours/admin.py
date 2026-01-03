from django.contrib import admin
from app.tours.location.models import *
from .models import (
    Tour,
)

admin.site.register(Tour)
admin.site.register(Division)
admin.site.register(District)
admin.site.register(Upazila)

