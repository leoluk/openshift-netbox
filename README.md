# openshift-netbox

OpenShift/okd.io[1] deployment for Netbox.

Requires a cluster with persistent storage. Make sure that the `oc` client is 
set up for the right project before you deploy.

Create application:

    oc process -f openshift/netbox-base.yaml | oc create -f -
    oc process -f openshift/netbox.yaml FQDN=netbox.example.com | oc create -f -

Tear down:

    oc delete all,secret,pvc,configmap -l app=netbox

Rebuild:

    oc start-build netbox-base -F
    oc start-build netbox -F

Rebuild base image from local repo:

    oc start-build -F netbox-base --from-dir=.

Create superuser:

    oc rsh dc/netbox netbox/manage.py createsuperuser
    
Import fixtures (if desired):
    
    oc rsh dc/netbox netbox/manage.py loaddata initial_data
    
Refer to the installation instructions for further steps:

    https://netbox.readthedocs.io/en/stable/installation/2-netbox/


[1]: https://github.com/openshift/origin
