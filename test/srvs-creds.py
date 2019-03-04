
#
# Creates the services and credenials needed for the ESA Swarm/Minio
# infrastructure for GNSS.
#

from slipstream.api import Api
from nuvla.api import Api as nuvla_Api

nuvla_api = nuvla_Api('https://localhost', insecure=True)

nuvla_api.login_internal('super', 'supeRsupeR')

#
# Create infrastructure-service-group to hold the services running at
# ESA.
#

group = {"name": "GNSS Big Data",
         "description": "Services running at ESA for the GNSS Big Data project",
         "documentation": "https://gssc.esa.int/"}

isg_response = nuvla_api.add('infrastructure-service-group', group)
isg_id = isg_response.data['resource-id']
print("ISG id: %s\n" % isg_id)


#
# Swarm service
#

swarm_tpl = {"template": { "href": "infrastructure-service-template/generic",
                           "parent": isg_id,
                           "name": "GNSS Swarm",
                           "description": "Docker Swarm cluster at ESA for GNSS",
                           "type": "swarm",
                           "endpoint": "https://swarm-gnss.esa.int:2376",
                           "state": "STARTED"}}

swarm_srv_response = nuvla_api.add('infrastructure-service', swarm_tpl)
swarm_id = swarm_srv_response.data['resource-id']
print("Swarm service id: %s\n" % swarm_id)

#
# Minio (S3) service
#

minio_tpl = {"template": { "href": "infrastructure-service-template/generic",
                           "parent": isg_id,
                           "name": "GNSS Minio (S3)",
                           "description": "Minio (S3) service at ESA for GNSS",
                           "type": "s3",
                           "endpoint": "http://minio-gnss.esa.int:9000",
                           "state": "STARTED"}}

minio_srv_response = nuvla_api.add('infrastructure-service', minio_tpl)
minio_id = minio_srv_response.data['resource-id']
print("Minio service id: %s\n" % minio_id)

#
# Swarm credential
#

swarm_cred_tpl = {"name": "GNSS Swarm Credential",
                  "description": "Certificate, Key, and CA for GNSS Swarm",
                  "template": {"href": "credential-template/infrastructure-service-swarm",
                               "services": [swarm_id],
                               "ca": "my-ca",
                               "cert": "my-cert",
                               "key": "my-key"}}

swarm_cred_response = nuvla_api.add('credential', swarm_cred_tpl)
swarm_cred_id = swarm_cred_response.data['resource-id']
print("Swarm credential id: %s\n" % minio_id)

#
# FIXME: Add credential for Minio (S3)
#

#
# Add dataset definitions.
#

data_set = {"name" : "GREAT (CLK)",
            "description" : "GREAT (CLK) data at ESA",
            "module-filter" : "data-accept-content-types='application/x-clk'",
            "data-object-filter" : "resource:type='DATA' and gnss:mission='great' and data:contentType='application/x-clk'"}

data_set_response = nuvla_api.add('data-set', data_set)
data_set_id = data_set_response.data['resource-id']
print("data-set id: %s\n" % data_set_id)


data_set = {"name" : "GOCE (HDR)",
            "description" : "GOCE (HDR) data at ESA",
            "module-filter" : "data-accept-content-types='application/x-hdr'",
            "data-record-filter" : "resource:type='DATA' and gnss:mission='goce' and data:contentType='application/x-hdr'"}

data_set_response = nuvla_api.add('data-set', data_set)
data_set_id = data_set_response.data['resource-id']
print("data-set id: %s\n" % data_set_id)


dataset = {"name" : "GOCE (DBL)",
           "description" : "GOCE (DBL) data at ESA",
           "module-filter" : "data-accept-content-types='application/x-dbl'",
           "data-record-filter" : "resource:type='DATA' and gnss:mission='goce' and data:contentType='application/x-dbl'"}

data_set_response = nuvla_api.add('data-set', data_set)
data_set_id = data_set_response.data['resource-id']
print("data-set id: %s\n" % data_set_id)


#
# Add component for GNSS Python application
#

gnss_comp = {"author": "esa",
             "commit": "initial commit",
             "architecture": "x86",
             "image": "sixsq/gnss-jupyter:latest"}

gnss_module = {"name": "GNSS Jupyter Notebook",
               "description": "Jupyter notebook application integrated with Nuvla data management",
               "type": "COMPONENT",
               "path": "gnss-jupyter",
               "parent-path": "",
               "content": gnss_comp}

gnss_module_response = nuvla_api.add('module', gnss_module)
gnss_module_id = gnss_module_response.data['resource-id']
print("module id: %s\n" % gnss_module_id)


#
# create deployment
#

deployment = {"module": {"href": gnss_module_id},
              "infrastructure-service-id": swarm_id,
              "credential-id": swarm_cred_id}

deployment_response = nuvla_api.add('deployment', deployment)
deployment_id = deployment_response.data['resource-id']
print("deployment id: %s\n" % deployment_id)

