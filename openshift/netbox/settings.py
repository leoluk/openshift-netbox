"""
Override the Netbox settings.py for customizations outside of configuration.py.
"""

import os
import requests

from netbox.upstream_settings import *

# Serve static files

MIDDLEWARE = (
    'whitenoise.middleware.WhiteNoiseMiddleware',
) + MIDDLEWARE

# OpenShift OAuth monkey patching

MIDDLEWARE = [
    'netbox.openshift_middleware.CustomLoginRequiredMiddleware' if
        x == 'utilities.middleware.LoginRequiredMiddleware' else x
    for x in MIDDLEWARE]

AUTHENTICATION_BACKENDS = (
    'netbox.openshift_auth.OpenshiftOAuth2',
)

LOGIN_URL = '/oauth/login/openshift'

ROOT_URLCONF = 'netbox.openshift_urls'

INSTALLED_APPS = INSTALLED_APPS + [
    'social_django',
]

SOCIAL_AUTH_POSTGRES_JSONFIELD = True

DEBUG = (os.getenv("NETBOX_DEBUG") == "True")

# OpenShift OAuth2

k8s_namespace = open("/var/run/secrets/kubernetes.io/serviceaccount/namespace").read()
SOCIAL_AUTH_VERIFY_SSL = "/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"

SOCIAL_AUTH_OPENSHIFT_SCOPE = ["user:info", "user:check-access"]
SOCIAL_AUTH_OPENSHIFT_KEY = "system:serviceaccount:{}:netbox".format(k8s_namespace)
SOCIAL_AUTH_OPENSHIFT_SECRET = open("/var/run/secrets/kubernetes.io/serviceaccount/token").read()
