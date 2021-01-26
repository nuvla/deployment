FROM nuvla/job-docker-compose-client:master

ARG workdir="/opt/nuvlabox"

WORKDIR ${workdir}

COPY . .

COPY target/ .

ENV PATH="$PATH:${workdir}/common:${workdir}/commands" \
    WORKDIR="${workdir}" \
    ROOTFS="/rootfs"

ENTRYPOINT ["./installer"]