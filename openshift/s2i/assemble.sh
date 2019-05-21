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

# Revert commit that breaks 3rd party authentication
patch -R -p1 <<EOF
From 6f5c35c2781a1dab157313b1ef87de2ae8de92be Mon Sep 17 00:00:00 2001
From: Jeremy Stretch <jstretch@digitalocean.com>
Date: Thu, 28 Feb 2019 11:40:32 -0500
Subject: [PATCH] Force resolution of request User object when logging an
 object deletion (resolves intermittent test failures)

---
 netbox/extras/middleware.py | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/netbox/extras/middleware.py b/netbox/extras/middleware.py
index 16461c32a..38dde6275 100644
--- a/netbox/extras/middleware.py
+++ b/netbox/extras/middleware.py
@@ -29,7 +29,11 @@ def cache_changed_object(instance, **kwargs):

 def _record_object_deleted(request, instance, **kwargs):

-    # Record that the object was deleted.
+    # Force resolution of request.user in case it's still a SimpleLazyObject. This seems to happen
+    # occasionally during tests, but haven't been able to determine why.
+    assert request.user.is_authenticated
+
+    # Record that the object was deleted
     if hasattr(instance, 'log_change'):
         instance.log_change(request.user, request.id, OBJECTCHANGE_ACTION_DELETE)
EOF

fix-permissions /opt/app-root
