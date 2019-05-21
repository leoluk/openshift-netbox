"""
Override the Netbox urls.py for OAuth login
"""

from netbox.urls import *

urlpatterns = urlpatterns + [
    url(r'^oauth/', include('social_django.urls', namespace='social')),
]
