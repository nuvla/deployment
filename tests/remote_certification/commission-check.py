#!/usr/bin/env python3

import os
import time
import sys
sys.path.append('../')

from common.timeout import timeout
from common.nuvla_api import NuvlaApi

nuvla = NuvlaApi()
nuvla.login()


def test_nuvlaedge_is_commissioned(request):
    nuvlaedge_id = os.environ.get('NUVLAEDGE_ID')
    error_msg = f'Waiting for NB {nuvlaedge_id} to get COMMISSIONED'

    with timeout(300, error_msg):
        while True:
            nuvlaedge = nuvla.api.get(nuvlaedge_id)
            if nuvlaedge.data.get('state', 'UNKNOWN') == 'COMMISSIONED':
                break

            time.sleep(3)

    assert nuvlaedge.data['state'] == 'COMMISSIONED', \
        f'NuvlaEdge {nuvlaedge_id} did not commission'
