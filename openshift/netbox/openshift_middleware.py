"""
Custom LOGIN_REQUIRED middleware which allows OAuth URLs.
"""

import utilities.middleware
from django.conf import settings


class CustomLoginRequiredMiddleware(utilities.middleware.LoginRequiredMiddleware):
    def __call__(self, request):
        if settings.LOGIN_REQUIRED and not request.user.is_authenticated:
            if request.path_info.startswith('/oauth/'):
                return self.get_response(request)

        return super(CustomLoginRequiredMiddleware, self).__call__(request)
