#!/usr/bin/env python3

import os
import time
import sys
sys.path.append('../')

from common.nuvla_api import NuvlaApi
from common.timeout import timeout

nuvla = NuvlaApi()
nuvla.login()

nuvlaedge_id = os.environ.get('NUVLAEDGE_ID')

def test_nuvlaedge_exists(request):
    nuvlaedge = nuvla.api.get(nuvlaedge_id)
    request.config.cache.set('nuvlaedge', nuvlaedge.data)
    request.config.cache.set('nuvlaedge_status_id', nuvlaedge.data['nuvlabox-status'])
    request.config.cache.set('nuvlaedge_isg_id', nuvlaedge.data['infrastructure-service-group'])

def test_nuvlaedge_is_stable(request):
    nuvlaedge_status_id = request.config.cache.get('nuvlaedge_status_id', '')
    with timeout(180, f'Waited too long for container-stats'):
        while True:
            try:
                nuvlaedge_status = nuvla.api.get(nuvlaedge_status_id)
            except IndexError:
                nuvlaedge_status = {}
                pass

            if nuvlaedge_status.data.get('resources', {}).get('container-stats'):
                break

            time.sleep(3)

    request.config.cache.set('nuvlaedge_status', nuvlaedge_status.data)
    for container in nuvlaedge_status.data['resources']['container-stats']:
        assert container['container-status'].lower() in ['running', 'paused'], \
            f'NuvlaEdge container {container["name"]} is not running'

        assert container['restart-count'] == 0, \
            f'NuvlaEdge container {container["name"]} is unstable and restarting'

def test_nuvlaedge_infra(request):
    isg_id = request.config.cache.get('nuvlaedge_isg_id', '')

    # check IS
    err = "Unable to validate the NuvlaEdge's infrastructure-service"
    with timeout(300, err):
        search_filter = f'parent="{isg_id}" and subtype="swarm"'
        print('Searching for NuvlaEdge infrastructure-service: ' + search_filter)
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
        f'Cannot find credential for NuvlaEdge in {nuvla.api.endpoint}, with query: {query}'

    request.config.cache.set('infra_service', infra)
    request.config.cache.set('nuvlaedge_credential', nb_credential.resources[0].data)
    print(f'::set-nuvlaedge_credential_id{nb_credential.resources[0].data["id"]}::set-nuvlaedge_credential_id')

    credential = nb_credential.resources[0].data
    if credential.get('status', '') != "VALID":
        r = nuvla.api.get(credential['id'] + "/check")
        assert r.data.get('status') == 202, \
            f'Failed to create job to check credential {credential["id"]}'

        with timeout(30, f"Unable to check NuvlaEdge's credential for the compute infrastructure"):
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
            f'The NuvlaEdge compute credential is invalid'

def test_expected_attributes(request):
    infra = request.config.cache.get('infra_service', {})
    swarm_enabled = nuvla.api.get(infra['id']).data['swarm-enabled']
    nuvlaedge_status = request.config.cache.get('nuvlaedge_status', {})

    # update the status
    with timeout(120, 'VPN IP is not available in NuvlaEdge Status'):
        while True:
            nuvlaedge_status = nuvla.api.get(nuvlaedge_status['id']).data
            if nuvlaedge_status.get('ip') and nuvlaedge_status['ip'].startswith('10.'):
                break

            time.sleep(3)

    default_err_log_suffix = ': attribute missing from NuvlaEdge status'
    assert nuvlaedge_status.get('ip'), \
        f'IP{default_err_log_suffix}'

    assert nuvlaedge_status['ip'].startswith('10.'), \
        'VPN IP is not set'
    assert nuvlaedge_status.get('operating-system'), \
        f'Operating System{default_err_log_suffix}'

    assert nuvlaedge_status.get('architecture'), \
        f'Architecture{default_err_log_suffix}'

    assert nuvlaedge_status.get('hostname'), \
        f'Hostname{default_err_log_suffix}'

    assert nuvlaedge_status.get('hostname'), \
        f'Hostname{default_err_log_suffix}'

    assert nuvlaedge_status.get('last-boot'), \
        f'Last Boot{default_err_log_suffix}'

    assert nuvlaedge_status.get('nuvlabox-engine-version'), \
        f'NuvlaEdge Engine Version{default_err_log_suffix}'

    assert nuvlaedge_status.get('installation-parameters'), \
        f'Installation Parameters{default_err_log_suffix}'

    assert nuvlaedge_status.get('orchestrator'), \
        f'Orchestrator{default_err_log_suffix}'

    nuvlaedge = nuvla.api.get(nuvlaedge_id)
    assert 'NUVLA_JOB_PULL' in nuvlaedge.data.get('capabilities', []), \
        f'NuvlaEdge {nuvlaedge_id} is missing the  NUVLA_JOB_PULL capability'

    if swarm_enabled:
        assert nuvlaedge_status.get('node-id'), \
            f'Node ID{default_err_log_suffix}'

        assert nuvlaedge_status.get('cluster-id'), \
            f'Cluster ID{default_err_log_suffix}'

        assert nuvlaedge_status.get('cluster-node-role'), \
            f'Cluster Node Role{default_err_log_suffix}'

        assert nuvlaedge_status.get('cluster-nodes'), \
            f'Cluster Nodes{default_err_log_suffix}'

        assert nuvlaedge_status.get('cluster-managers'), \
            f'Cluster managers{default_err_log_suffix}'

        assert nuvlaedge_status.get('cluster-join-address'), \
            f'Cluster Join Address{default_err_log_suffix}'
