#!/usr/bin/env python3

import docker
import json
import logging
import os
import pytest
import requests
import sys
import time
import uuid

from git import Repo
from tempfile import NamedTemporaryFile

sys.path.append('../')


NUVLAEDGE_DATA_GATEWAY_IMAGE="eclipse-mosquitto:1.6.12"
NUVLAEDGE_IMMUTABLE_SSH_PUB_KEY="testpubkey"
VPN_INTERFACE_NAME="testvpn"
HOST="testnuvlaedge"
HOST_HOME=os.getenv('HOME')

local_project_name = str(uuid.uuid4())
nuvlaedge_id = os.environ.get('NUVLAEDGE_ID')
docker_client = docker.from_env()

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
    ssh_dir = HOST_HOME + "/.ssh"
    authorized_keys = ssh_dir + "/authorized_keys"

    assert os.path.isfile(authorized_keys), \
        f'Cannot find SSH keys file in {ssh_dir}: {os.listdir(ssh_dir)}'

    with open(authorized_keys) as ak:
        assert NUVLAEDGE_IMMUTABLE_SSH_PUB_KEY in ak.read()


def test_nuvlaedge_engine_local_compute_api(request):
    volume = docker_client.api.inspect_volume(local_project_name + "_nuvlabox-db").get('Mountpoint')
    request.config.cache.set('nuvlaedge_volume_path', volume)

    agent = docker_client.containers.get(local_project_name + "-agent")

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
    nuvlaedge_network = local_project_name + '-shared-network'

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

    def run_test_container():
        cmd = 'sh -c "apk add mosquitto-clients >/dev/null && mosquitto_sub -h data-gateway -t nuvlaedge-status -C 1"'
        return docker_client.containers.run('alpine',
                                            command=cmd,
                                            network=nuvlaedge_network,
                                            remove=True)
    try:
        check_mqtt = run_test_container()
    except:
        logging.info(f'NuvlaEdge data-gateway not ready yet. Waiting 15 seconds and retry...')
        time.sleep(15)
        check_mqtt = run_test_container()

    nb_status = json.loads(check_mqtt.decode())
    assert nb_status['status'] == 'OPERATIONAL', f'MQTT check of the NuvlaEdge status failed: {nb_status}'

    logging.info('NuvlaEdge MQTT messaging is working')


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
#    agent = docker_client.containers.get(local_project_name + "-agent")

    # assert agent.exec_run('cat /srv/nuvlaedge/shared/vulnerabilities').exit_code == 0
