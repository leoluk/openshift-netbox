# openshift-netbox

**NOTE:** Multiple companies are using this in production, but the interfaces are
not stable yet. Take a look at changes and reconcile them with your production
setup before updating the base image or reapplying the k8s config!

OpenShift/okd.io[1] deployment for Netbox.

Requires a cluster with persistent storage. Make sure that the `oc` client is 
set up for the right project before you deploy.

Create application:

    oc process -f openshift/netbox-base.yaml | oc create -f -
    oc process -f openshift/netbox.yaml FQDN=netbox.example.com | oc create -f -

Tear down:

    oc delete all,secret,pvc,configmap,serviceaccount -l app=netbox

Rebuild:

    oc start-build netbox-base -F
    oc start-build netbox -F

Rebuild base image from local repo:

    oc start-build -F netbox-base --from-dir=.

Create superuser:

    oc rsh dc/netbox netbox/manage.py createsuperuser
    
Import fixtures (if desired):
    
    oc rsh dc/netbox netbox/manage.py loaddata initial_data
    
Give superuser permissions to a user:

    oc rsh dc/netbox netbox/manage.py shell
    
    >>> from django.contrib.auth.models import User
    >>> u = User.objects.get(id=1)
    >>> u.is_staff = True
    >>> u.is_superuser = True
    >>> u.save()

Database backup/restore:

    oc rsh --no-tty dc/netbox-db bash -c 'pg_dump --username=$POSTGRESQL_USER --format=custom $POSTGRESQL_DATABASE' > dumpfile
    oc rsh --no-tty dc/netbox-db bash -c 'pg_restore --username=$POSTGRESQL_USER --clean --dbname=$POSTGRESQL_DATABASE' < dumpfile

(Expect the error messages `must be owner of extension plpgsql` and `must be
owner of schema public` from `pg_restore`. These can be ignored.)

Media backup/restore:

    oc rsync $(oc get pods -l app=netbox -o name):/opt/app-root/media/ backup-directory/
    oc rsync backup-directory/ $(oc get pods -l app=netbox -o name):/opt/app-root/media/

Refer to the installation instructions for further steps:

    https://netbox.readthedocs.io/en/stable/installation/2-netbox/


[1]: https://github.com/openshift/origin
