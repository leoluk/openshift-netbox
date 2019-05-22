"""
Custom OpenShift OAuth2 provider
"""

# TODO: upstream to social-core

import requests

from django.views.generic import View
from django.http import HttpResponseRedirect
from django.contrib.auth import logout as auth_logout

from social_core.backends.oauth import BaseOAuth2


K8S_CA_FILE = "/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"
K8S_API = "https://openshift.default.svc"

class OpenshiftOAuth2(BaseOAuth2):
    name = 'openshift'
    ACCESS_TOKEN_METHOD = 'POST'

    k8s_oauth = requests.get(
        K8S_API + "/.well-known/oauth-authorization-server",
        verify=K8S_CA_FILE).json()

    def access_token_url(self):
        return K8S_API + "/oauth/token"

    def authorization_url(self):
        return self.k8s_oauth['authorization_endpoint']

    def get_user_id(self, details, response):
        return response['metadata']['uid']

    def get_user_details(self, response):
        """Return user details from OpenShift account"""

        username = response['metadata']['name']
        email = response['metadata']['name']

        full_name, first_name, last_name = self.get_user_names(
            response['fullName']
        )

        return {
            'username': username,
            'email': email,
            'fullname': full_name,
            'first_name': first_name,
            'last_name': last_name
        }

    def user_data(self, access_token, *args, **kwargs):
        """Loads user data from service"""

        headers = {'Authorization': 'Bearer ' + access_token}

        return requests.get(
            K8S_API + "/oapi/v1/users/~",
            verify=K8S_CA_FILE,
            headers=headers).json()

# Customized LogoutView that redirects to the OpenShift Console logout URI
class LogoutView(View):
    def get(self, request):
        # Log out the user
        auth_logout(request)

        # Log out from OpenShift Console
        response = HttpResponseRedirect(OpenshiftOAuth2.k8s_oauth['issuer'] + '/console/logout')

        # Delete session key cookie (if set) upon logout
        response.delete_cookie('session_key')

        return response
