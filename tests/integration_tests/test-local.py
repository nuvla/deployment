#!/usr/bin/env python3

import signal
import json
import docker
import pytest
import uuid
import requests
import logging
import os
import nuvla as nuvla_lib
from tempfile import NamedTemporaryFile
from git import Repo

import sys
sys.path.append('../')
from common.nuvla_api import NuvlaApi
from common.timeout import timeout


NUVLAEDGE_DATA_GATEWAY_IMAGE="eclipse-mosquitto:1.6.12"
NUVLAEDGE_IMMUTABLE_SSH_PUB_KEY="testpubkey"
VPN_INTERFACE_NAME="testvpn"
HOST="testnuvlaedge"
HOST_HOME=os.getenv('HOME')

local_project_name = str(uuid.uuid4())
nuvlaedge_id = os.environ.get('NUVLAEDGE_ID')
docker_client = docker.from_env()
nuvla = NuvlaApi()
nuvla.login()

# need to create .ssh folder otherwise the SSH key installation
# cannot be tested
os.system(f'mkdir -p {HOST_HOME}/.ssh')

cert = NamedTemporaryFile()
key = NamedTemporaryFile()

# cleaner = cleanup.Cleanup(api, docker_client)
# atexit.register(cleaner.goodbye)

repo = Repo("../..")
if repo.active_branch.name == "main":
    nbe_installer_image = "nuvlaedge/installer:main"
else:
    nbe_installer_image = f"nuvladev/installer:{repo.active_branch.name}"


def test_deploy_nuvlaedgees(request):
    assert nuvlaedge_id != '', 'Missing NuvlaEdge ID for local installation'

    # deploy local NB
    docker_client.images.pull(nbe_installer_image)
    request.config.cache.set('local_project_name', local_project_name)

    nb_env = f'NUVLAEDGE_UUID={nuvlaedge_id},HOST_HOME={HOST_HOME},SKIP_MINIMUM_REQUIREMENTS=True,'\
            f'NUVLAEDGE_DATA_GATEWAY_IMAGE={NUVLAEDGE_DATA_GATEWAY_IMAGE},'\
            f'NUVLAEDGE_SSH_PUB_KEY={NUVLAEDGE_IMMUTABLE_SSH_PUB_KEY},'\
            f'VPN_INTERFACE_NAME={VPN_INTERFACE_NAME},HOST={HOST}'
    try:
        docker_client.containers.run(nbe_installer_image,
                                    command=f"install --project={local_project_name} --daemon --environment={nb_env}",
                                    name="nuvlaedge-engine-installer",
                                    volumes={
                                        '/var/run/docker.sock': {'bind': '/var/run/docker.sock',
                                                                'mode': 'ro'}
                                    })
    except docker.errors.ContainerError as e:
        logging.error(f'Cannot install local NuvlaEdge Engine. Reason: {str(e)}')

    installer_container = docker_client.containers.get("nuvlaedge-engine-installer")

    assert installer_container.attrs['State']['ExitCode'] == 0, 'NBE installer failed'
    logging.info(f'NuvlaEdge ({nuvlaedge_id}) Engine successfully installed with project name {local_project_name}')


def test_nuvlaedge_engine_containers_stability(request):
    nb_containers = docker_client.containers.list(filters={'label': 'nuvlaedge.component=True'}, all=True)

    container_names = []
    image_names = []
    for container in nb_containers:
        image_names.append(container.attrs['Config']['Image'])

        assert (container.attrs['RestartCount'] == 0 or container.attrs.get('State', {}).get('ExitCode', 0) == 0), \
            f'Local NuvlaEdge container {container.name} is unstable: {json.dumps(container.attrs, indent=2)}\n\n' \
                f'Logs: {container.logs()}'

        # we allow for containers to have exited, provided they have exited without an error
        # like this we cover scenarios where, for example, a peripheral manager is not supported by the testing env
        if container.status.lower() not in ['running', 'paused'] and container.attrs['State']['ExitCode'] == 0:
            logging.warning(f'Container {container.name} is "{container.status}" but with exit code 0. Ignoring it ...')
            continue

        assert container.status.lower() in ['running', 'paused'], \
            f'Local NuvlaEdge container {container.name} is not running. Logs are: {container.logs()}. ' \
                f'Details: {json.dumps(container.attrs, indent=2)}'

        container_names.append(container.name)

    logging.info('All NuvlaEdge containers from local installation are stable')
    request.config.cache.set('containers', container_names)
    request.config.cache.set('images', image_names)


def test_ssh_key_bootstrap():
    authorized_keys = HOST_HOME + "/.ssh/authorized_keys"
    assert os.path.isfile(authorized_keys), \
        f'Cannot find SSH keys file in {HOST_HOME}: {os.listdir(HOST_HOME)}'

    with open(authorized_keys) as ak:
        assert NUVLAEDGE_IMMUTABLE_SSH_PUB_KEY in ak.read()


def test_nuvlaedge_engine_local_agent_api(request):
    agent_api = 'http://localhost:5080/api/'
    r = requests.get(agent_api + 'healthcheck')
    assert r.status_code == 200, f'{agent_api} is not up'
    assert 'true' in r.text.lower(), f'{agent_api} is unhealthy'
    logging.info(f'Agent API ({agent_api}) is healthy')

    # send commissioning
    commission = {
        'tags': ['TEST_TAG']
    }
    r = requests.post(agent_api + 'commission', json=commission)
    assert r.status_code == 200, f'Commissioning {commission} via {agent_api}, has failed'
    logging.info(f'NuvlaEdge commissioning is working (tested with payload: {commission})')

    nuvlaedge = nuvla.api.get(nuvlaedge_id)
    assert 'TEST_TAG' in nuvlaedge.data.get('tags', []), f'Commissioning false positive. Tags were not propagated'
    request.config.cache.set('nuvlaedge_id_local_isg', nuvlaedge.data['infrastructure-service-group'])

    # check peripherals api
    mock_peripheral_identifier = 'mock:usb:peripheral'
    mock_peripheral = {
        'identifier': mock_peripheral_identifier,
        'interface': 'USB',
        'version': int(nuvlaedge.data['version']),
        'name': '(local NB) Mock USB Peripheral',
        'available': True,
        'classes': ['video']
    }
    r = requests.post(agent_api + 'peripheral', json=mock_peripheral)
    assert r.status_code == 201, f'Unable to add new peripheral via {agent_api}'

    mock_peripheral_id = r.json()['resource-id']

    r = requests.get(agent_api + 'peripheral')
    assert r.status_code == 200, f'Unable to get peripherals via {agent_api}'
    assert mock_peripheral_identifier in r.json(), f'Wrong format while getting peripherals via {agent_api}'

    r = requests.get(agent_api + 'peripheral/' + mock_peripheral_identifier)
    assert r.status_code == 200, f'Unable to get specific peripheral via {agent_api}'
    assert isinstance(r.json(), dict), f'Wrong format while getting peripheral via {agent_api}'
    assert mock_peripheral_id == r.json()['id'], \
        f'Peripheral returned by {agent_api} does not match ID {mock_peripheral_id}'

    new_description = 'new test description'
    r = requests.put(agent_api + 'peripheral/' + mock_peripheral_identifier, json={'description': new_description})
    assert r.status_code == 200, f'Unable to edit peripheral via {agent_api}'
    assert r.json().get('description', '') == new_description, 'Edited peripheral is not up to date'

    r = requests.get(agent_api + 'peripheral?identifier_pattern=mock*')
    assert r.status_code == 200, f'Unable to get peripheral by pattern via {agent_api}'
    assert isinstance(r.json(), dict), f'Wrong format while getting peripheral via {agent_api}'
    assert mock_peripheral_id == r.json()[mock_peripheral_identifier]['id'], \
        f'Peripheral returned by {agent_api} does not match ID {mock_peripheral_id}'

    r = requests.get(agent_api + 'peripheral?identifier_pattern=bad-peripheral')
    assert r.status_code == 200, f'Unable to get peripheral by pattern via {agent_api}'
    assert not r.json(), f'{agent_api} returned some peripheral while it should have returned None'

    # 2nd peripheral
    mock_peripheral_identifier_two = 'mock:usb:peripheral:2'
    mock_peripheral.update({
        'identifier': mock_peripheral_identifier_two,
        'name': '(local NB) Mock USB Peripheral 2'
    })
    r = requests.post(agent_api + 'peripheral', json=mock_peripheral)
    assert r.status_code == 201, f'Unable to add new peripheral via {agent_api}'

    request.config.cache.set('peripheral_id', r.json()['resource-id'])

    r = requests.get(agent_api + 'peripheral?identifier_pattern=mock*')
    assert r.status_code == 200, f'Unable to get peripheral by pattern via {agent_api}'
    assert isinstance(r.json(), dict), f'Wrong format while getting peripheral via {agent_api}'
    assert len(r.json().keys()) == 2, f'{agent_api} should have returned 2 peripherals'

    r = requests.get(agent_api + 'peripheral?parameter=description&value=' + new_description)
    assert r.status_code == 200, f'Unable to get peripheral by param/value via {agent_api}'
    assert isinstance(r.json(), dict), f'Wrong format while getting peripheral via {agent_api}'
    assert len(r.json().keys()) == 1, 'Returned peripherals that do not match param/value'

    r = requests.delete(agent_api + 'peripheral/' + mock_peripheral_identifier)
    assert r.status_code == r.json()['status'] == 200, f'Cannot delete peripheral via {agent_api}'
    assert r.json()['resource-id'] == mock_peripheral_id, f'ID mismatch while deleting peripheral via {agent_api}'

    with pytest.raises(nuvla_lib.api.api.NuvlaError):
        nuvla.api.get(mock_peripheral_id)

    logging.info(f'Agent API ({agent_api}) for peripheral management is up and running')


def test_nuvlaedge_engine_local_compute_api(request):
    volume = docker_client.api.inspect_volume(local_project_name + "_nuvlabox-db").get('Mountpoint')
    request.config.cache.set('nuvlaedge_volume_path', volume)

    agent = docker_client.containers.get(local_project_name + "_agent_1")

    raw_cert = agent.exec_run('cat /srv/nuvlaedge/shared/cert.pem').output
    cert.write(raw_cert)
    cert.flush()

    raw_key = agent.exec_run('cat /srv/nuvlaedge/shared/key.pem').output
    key.write(raw_key)
    key.flush()

    compute_api = 'https://localhost:5000/'

    r = requests.get(compute_api + 'containers/json', verify=False, cert=(cert.name, key.name))
    assert r.status_code == 200, f'NuvlaEdge compute API {compute_api} is not working'
    assert len(r.json()) > 0, \
        f'NuvlaEdge compute API {compute_api} should have reported (at least) the NuvlaEdge containers'

    logging.info(f'Compute API ({compute_api}) is up, running and secured')


def test_nuvlaedge_engine_local_datagateway():
    nuvlaedge_network = 'nuvlaedge-shared-network'

    docker_net = None
    try:
        docker_net = docker_client.networks.get(nuvlaedge_network)
    except docker.errors.NotFound:
        logging.warning(f'NuvlaEdge network {nuvlaedge_network} not found')

    assert nuvlaedge_network == docker_net.name, f'Network {nuvlaedge_network} does not exist'

    check_dg = docker_client.containers.run('alpine',
                                            command='sh -c "ping -c 1 data-gateway 2>&1 >/dev/null && echo OK"',
                                            network=nuvlaedge_network,
                                            remove=True)

    assert 'OK' in check_dg.decode(), f'Cannot reach Data Gateway containers: {check_dg}'

    logging.info(f'NuvlaEdge shared network ({nuvlaedge_network}) is functional')

    cmd = 'sh -c "apk add mosquitto-clients >/dev/null && mosquitto_sub -h data-gateway -t nuvlaedge-status -C 1"'
    check_mqtt = docker_client.containers.run('alpine',
                                            command=cmd,
                                            network=nuvlaedge_network,
                                            remove=True)

    nb_status = json.loads(check_mqtt.decode())
    assert nb_status['status'] == 'OPERATIONAL', f'MQTT check of the NuvlaEdge status failed: {nb_status}'

    logging.info('NuvlaEdge MQTT messaging is working')


def test_nuvlaedge_engine_local_system_manager():
    system_manager_dashboard = 'http://127.0.0.1:3636/dashboard'

    r = requests.get(system_manager_dashboard)
    assert r.status_code == 200, f'Internal NuvlaEdge dashboard {system_manager_dashboard} is down'
    assert 'NuvlaEdge Local Dashboard' in r.text, \
        f'Internal NuvlaEdge dashboard {system_manager_dashboard} has wrong content'

    r = requests.get(system_manager_dashboard + '/logs')
    assert r.status_code == 200, f'Internal NuvlaEdge dashboard {system_manager_dashboard}/logs is down'
    assert 'NuvlaEdge Local Dashboard - Logs' in r.text, \
        f'Internal NuvlaEdge dashboard {system_manager_dashboard}/logs has wrong content'

    r = requests.get(system_manager_dashboard + '/peripherals')
    assert r.status_code == 200, f'Internal NuvlaEdge dashboard {system_manager_dashboard}/peripherals is down'
    assert 'NuvlaEdge Local Dashboard - Peripherals' in r.text, \
        f'Internal NuvlaEdge dashboard {system_manager_dashboard}/peripherals has wrong content'

    logging.info(f'NuvlaEdge internal dashboard ({system_manager_dashboard}) is up and running')


def test_cis_benchmark(request):
    containers = request.config.cache.get('containers', [])
    images = request.config.cache.get('images', [])

    log_file = '/tmp/cis_log'
    cmd = f'-l {log_file} -c container_images,container_runtime -i {",".join(containers)} -t {",".join(images)}'
    docker_client.containers.run('docker/docker-bench-security',
                                    network_mode='host',
                                    pid_mode='host',
                                    userns_mode='host',
                                    remove=True,
                                    cap_add='audit_control',
                                    environment=[f'DOCKER_CONTENT_TRUST={os.getenv("DOCKER_CONTENT_TRUST")}'],
                                    volumes={
                                        '/etc': {'bind': '/etc', 'mode': 'ro'},
                                        '/usr/bin/docker-containerd': {'bind': '/usr/bin/docker-containerd',
                                                                    'mode': 'ro'},
                                        '/usr/bin/runc': {'bind': '/usr/bin/runc', 'mode': 'ro'},
                                        '/usr/lib/systemd': {'bind': '/usr/lib/systemd', 'mode': 'ro'},
                                        '/var/lib': {'bind': '/var/lib', 'mode': 'ro'},
                                        '/var/run/docker.sock': {'bind': '/var/run/docker.sock', 'mode': 'ro'},
                                        '/tmp': {'bind': '/tmp', 'mode': 'rw'}
                                    },
                                    labels=["docker_bench_security"],
                                    command=cmd)

    with open(log_file) as r:
        out = r.readlines()

    score = 0
    reference_score = -10
    for line in out:
        if 'Score: ' in line:
            score = int(line.strip().split(' ')[-1])

    assert score >= reference_score, \
        f'CIS benchmark failed with a low score of {score}. Containers: {containers}. Images: {images}'
    logging.info(f'CIS benchmark finished with a final score of {score}')

# TODO: this cannot be easily tested anymore since it now has a delayed start, and takes longer
#def test_security_scanner(request):
#    agent = docker_client.containers.get(local_project_name + "_agent_1")

    # assert agent.exec_run('cat /srv/nuvlaedge/shared/vulnerabilities').exit_code == 0
