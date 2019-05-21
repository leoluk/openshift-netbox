"""
Override the Netbox urls.py for OAuth login
"""

from netbox.urls import *
from netbox.openshift_auth import LogoutView

urlpatterns = [
    url(r'^logout/$', LogoutView.as_view(), name='logout'),
] + urlpatterns + [
    url(r'^oauth/', include('social_django.urls', namespace='social')),
]
