#!/bin/bash -xe

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
