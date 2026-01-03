from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    path('auth/', include('app.accounts.urls')),
    path('tour/', include('app.tours.urls')),
]
