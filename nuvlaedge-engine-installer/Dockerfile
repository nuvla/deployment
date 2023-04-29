FROM python:3.8-alpine3.12

ARG workdir="/opt/nuvlaedge"

WORKDIR ${workdir}

COPY --from=nuvla/job-docker-compose-client:master /usr/local/bin/docker-compose /usr/local/bin/
COPY --from=nuvla/job-docker-compose-client:master /usr/local/lib/python3.8/site-packages /usr/local/lib/python3.8/site-packages

COPY . .

COPY target/ .

RUN apk add jq

ENV PATH="$PATH:${workdir}/common:${workdir}/commands" \
    WORKDIR="${workdir}" \
    ROOTFS="/rootfs"  \
    ROOTFS_WORKING_DIR="/rootfs-working-dir"

RUN chmod +x installer

ENTRYPOINT ["./installer"]
