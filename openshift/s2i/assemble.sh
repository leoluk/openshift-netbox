#!/bin/bash

set -e

shopt -s dotglob
echo "---> Installing application source ..."
mv /tmp/src/* "$HOME"

echo "---> Installing dependencies ..."
pip install -r requirements.txt

echo "---> Installing extra dependencies ..."
pip3 install gunicorn==19.9.0
pip3 install whitenoise==4.1.2

# Custom settings.py
mv netbox/netbox/settings.py netbox/netbox/upstream_settings.py
cp /opt/app-root/etc/settings.py netbox/netbox/settings.py

fix-permissions /opt/app-root
