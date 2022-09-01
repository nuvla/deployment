#!/usr/bin/env python3

import logging
import sys
sys.path.append('../')

from common.nuvla_api import NuvlaApi

nuvla = NuvlaApi()


def test_nuvla_login():
    logging.info('Fetching Nuvla API key credential from environment...')
    assert nuvla.apikey.startswith("credential/"), "A valid Nuvla API key needs to start with 'credential/'"

    logging.info(f'Authenticating with Nuvla at {nuvla.endpoint}')
    nuvla.login()
    assert nuvla.api.is_authenticated(), "The provided Nuvla API key credential is not valid"


def test_zero_nuvlaedges():
    logging.info('We shall not run this test if there are leftover NuvlaEdge resources in Nuvla...')
    search_filter = 'name^="[CI/CD Remote Certification " and state="COMMISSIONED"'
    existing_nuvlaedges = nuvla.api.get('nuvlabox',
                                        filter=search_filter)
    # if there are NBs then it means a previous test run left uncleaned resources. This must be fixed manually
    assert existing_nuvlaedges.data.get('count', 0) == 0, 'There are leftovers from previous tests'
