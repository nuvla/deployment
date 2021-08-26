#!/usr/bin/env python3

import os
import time
import sys
sys.path.append('../')

from common.nuvla_api import NuvlaApi
from common.timeout import timeout

nuvla = NuvlaApi()
nuvla.login()

nuvlabox_id = os.environ.get('NUVLABOX_ID')

def test_nuvlabox_exists(request):
    nuvlabox = nuvla.api.get(nuvlabox_id)
    request.config.cache.set('nuvlabox', nuvlabox.data)
    request.config.cache.set('nuvlabox_status_id', nuvlabox.data['nuvlabox-status'])
    request.config.cache.set('nuvlabox_isg_id', nuvlabox.data['infrastructure-service-group'])

def test_nuvlabox_is_stable(request):
    nuvlabox_status_id = request.config.cache.get('nuvlabox_status_id', '')
    with timeout(180, f'Waited too long for container-stats'):
        while True:
            try:
                nuvlabox_status = nuvla.api.get(nuvlabox_status_id)
            except IndexError:
                nuvlabox_status = {}
                pass

            if nuvlabox_status.data.get('resources', {}).get('container-stats'):
                break

            time.sleep(3)

    request.config.cache.set('nuvlabox_status', nuvlabox_status.data)
    for container in nuvlabox_status.data['resources']['container-stats']:
        assert container['container-status'].lower() in ['running', 'paused'], \
            f'NuvlaBox container {container["name"]} is not running'

        assert container['restart-count'] == 0, \
            f'NuvlaBox container {container["name"]} is unstable and restarting'

def test_nuvlabox_infra(request):
    isg_id = request.config.cache.get('nuvlabox_isg_id', '')

    # check IS
    err = "Unable to validate the NuvlaBox's infrastructure-service"
    with timeout(300, err):
        search_filter = f'parent="{isg_id}" and subtype="swarm"'
        print('Searching for NuvlaBox infrastructure-service: ' + search_filter)
        while True:
            infras = nuvla.api.search('infrastructure-service',
                                    filter=search_filter)

            if infras.count == 0:
                time.sleep(2)
                continue

            infra = infras.resources[0].data
            if infra.get('endpoint').startswith('https://10.'):
                break
            else:
                time.sleep(2)

    cred_subtype = "infrastructure-service-swarm"
    query = f'parent="{infra["id"]}" and subtype="{cred_subtype}"'
    nb_credential = nuvla.api.search('credential', filter=query)
    assert nb_credential.count == 1, \
        f'Cannot find credential for NuvlaBox in {nuvla.api.endpoint}, with query: {query}'

    request.config.cache.set('infra_service', infra)
    request.config.cache.set('nuvlabox_credential', nb_credential.resources[0].data)
    print(f'::set-nuvlabox_credential_id{nb_credential.resources[0].data["id"]}::set-nuvlabox_credential_id')

    credential = nb_credential.resources[0].data
    if credential.get('status', '') != "VALID":
        r = nuvla.api.get(credential['id'] + "/check")
        assert r.data.get('status') == 202, \
            f'Failed to create job to check credential {credential["id"]}'

        with timeout(30, f"Unable to check NuvlaBox's credential for the compute infrastructure"):
            while True:
                j_status = nuvla.api.get(r.data.get('location'))
                if j_status.data['progress'] < 100:
                    time.sleep(1)
                    continue

                assert j_status.data['state'] == 'SUCCESS', \
                    f'Failed to perform credential check. Reason: {j_status.data.get("status-message")}'

                break

        credential = nuvla.api.get(credential['id'])
        assert credential.data['status'] == 'VALID', \
            f'The NuvlaBox compute credential is invalid'

def test_expected_attributes(request):
    infra = request.config.cache.get('infra_service', {})
    swarm_enabled = nuvla.api.get(infra['id']).data['swarm-enabled']
    nuvlabox_status = request.config.cache.get('nuvlabox_status', {})

    # update the status
    with timeout(120, 'VPN IP is not available in NuvlaBox Status'):
        while True:
            nuvlabox_status = nuvla.api.get(nuvlabox_status['id']).data
            if nuvlabox_status.get('ip') and nuvlabox_status['ip'].startswith('10.'):
                break

            time.sleep(3)

    default_err_log_suffix = ': attribute missing from NuvlaBox status'
    assert nuvlabox_status.get('ip'), \
        f'IP{default_err_log_suffix}'

    assert nuvlabox_status['ip'].startswith('10.'), \
        'VPN IP is not set'
    assert nuvlabox_status.get('operating-system'), \
        f'Operating System{default_err_log_suffix}'

    assert nuvlabox_status.get('architecture'), \
        f'Architecture{default_err_log_suffix}'

    assert nuvlabox_status.get('hostname'), \
        f'Hostname{default_err_log_suffix}'

    assert nuvlabox_status.get('hostname'), \
        f'Hostname{default_err_log_suffix}'

    assert nuvlabox_status.get('last-boot'), \
        f'Last Boot{default_err_log_suffix}'

    assert nuvlabox_status.get('nuvlabox-engine-version'), \
        f'NuvlaBox Engine Version{default_err_log_suffix}'

    assert nuvlabox_status.get('installation-parameters'), \
        f'Installation Parameters{default_err_log_suffix}'

    assert nuvlabox_status.get('orchestrator'), \
        f'Orchestrator{default_err_log_suffix}'

    nuvlabox = nuvla.api.get(nuvlabox_id)
    assert 'NUVLA_JOB_PULL' in nuvlabox.data.get('capabilities', []), \
        f'NuvlaBox {nuvlabox_id} is missing the  NUVLA_JOB_PULL capability'

    if swarm_enabled:
        assert nuvlabox_status.get('node-id'), \
            f'Node ID{default_err_log_suffix}'

        assert nuvlabox_status.get('cluster-id'), \
            f'Cluster ID{default_err_log_suffix}'

        assert nuvlabox_status.get('cluster-node-role'), \
            f'Cluster Node Role{default_err_log_suffix}'

        assert nuvlabox_status.get('cluster-nodes'), \
            f'Cluster Nodes{default_err_log_suffix}'

        assert nuvlabox_status.get('cluster-managers'), \
            f'Cluster managers{default_err_log_suffix}'

        assert nuvlabox_status.get('cluster-join-address'), \
            f'Cluster Join Address{default_err_log_suffix}'


