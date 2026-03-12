from django.contrib import admin
from django.urls import path, include
from django.contrib.staticfiles.urls import staticfiles_urlpatterns

urlpatterns = [
    path('admin/', admin.site.urls),
    path('auth/', include('app.accounts.urls')),
    path('tour/', include('app.tours.urls')),
    path('notification/', include('app.notification.urls')),
]

urlpatterns += staticfiles_urlpatterns()
