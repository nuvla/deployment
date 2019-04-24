#!/bin/bash -xe

#
# SSH key to use for Swarm deployment
#
# You should use an SSH key that is not password
# protected to avoid having to repeatedly enter
# your password.
#
# This is the default value if not specified.
# 

# export SSH_KEY=${HOME}/.ssh/id_rsa

#
# Administrator username and password
#
# The default username/password is admin/admin.
#

export ADMIN_USERNAME=admin
export ADMIN_PASSWORD=admin

export ADMIN_HASHED_PASSWORD=`htpasswd -nbB ${ADMIN_USERNAME} ${ADMIN_PASSWORD} | head -1 | cut -d : -f 2 | sed 's/\$/\$\$/g'`

#
# Grafana email notifications
#
# enable and provide correct values if you want
# these notifications (optional)
#

export GF_SMTP_ENABLED=false
export GF_SMTP_FROM_ADDRESS=nuvla@example.com
export GF_SMTP_FROM_NAME=nuvla
export GF_SMTP_HOST=smtp.example.com:465
export GF_SMTP_USER=nuvla@example.com
export GF_SMTP_PASSWORD=clear-text-password

#
# Parameters for the Exoscale cloud
#
# The region defaults to CH-GVA-2.
#

export EXOSCALE_API_KEY='key'
export EXOSCALE_API_SECRET='secret'
#export EXOSCALE_REGION=CH-GVA-2
