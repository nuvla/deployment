#!/usr/bin/env python3

import os
from nuvla.api import Api

class NuvlaApi(object):
    def __init__(self):
        self.endpoint = os.getenv('NUVLA_ENDPOINT', "https://nuvla.io")
        self.api = Api(endpoint=self.endpoint, reauthenticate=True)
        self.apikey = os.getenv('NUVLA_DEV_APIKEY')
        self.apisecret = os.getenv('NUVLA_DEV_APISECRET')

    def login(self):
        self.api.login_apikey(self.apikey, self.apisecret)
