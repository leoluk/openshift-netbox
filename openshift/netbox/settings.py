"""
Override the Netbox settings.py for customizations outside of configuration.py.
"""

from netbox.upstream_settings import *

MIDDLEWARE = (
    'whitenoise.middleware.WhiteNoiseMiddleware',
) + MIDDLEWARE
