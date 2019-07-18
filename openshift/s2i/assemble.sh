#!/bin/bash

set -e

shopt -s dotglob
echo "---> Installing application source ..."
mv /tmp/src/* "$HOME"

echo "---> Installing dependencies ..."
pip install -r requirements.txt

echo "---> Installing extra dependencies ..."
pip3 install \
    gunicorn==19.9.0 \
    whitenoise==4.1.2 \
    social-auth-core==3.1.0 \
    social-auth-app-django==3.1.0

# Custom settings.py
mv netbox/netbox/settings.py netbox/netbox/upstream_settings.py
cp /opt/app-root/etc/settings.py netbox/netbox/settings.py
cp /opt/app-root/etc/openshift_urls.py netbox/netbox/openshift_urls.py
cp /opt/app-root/etc/openshift_middleware.py netbox/netbox/openshift_middleware.py
cp /opt/app-root/etc/openshift_auth.py netbox/netbox/openshift_auth.py

fix-permissions /opt/app-root
