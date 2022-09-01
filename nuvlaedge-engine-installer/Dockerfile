FROM nuvla/job-docker-compose-client:master

ARG workdir="/opt/nuvlaedge"

WORKDIR ${workdir}

COPY . .

COPY target/ .

RUN apk add jq

ENV PATH="$PATH:${workdir}/common:${workdir}/commands" \
    WORKDIR="${workdir}" \
    ROOTFS="/rootfs"  \
    ROOTFS_WORKING_DIR="/rootfs-working-dir"

ENTRYPOINT ["./installer"]
