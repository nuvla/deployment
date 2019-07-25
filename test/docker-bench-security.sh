#!/usr/bin/env bash

docker run -it --net host --pid host --userns host --cap-add audit_control  \
   -e DOCKER_CONTENT_TRUST=$DOCKER_CONTENT_TRUST \
   -v /etc:/etc     \
   -v /usr/bin/docker-containerd:/usr/bin/docker-containerd     \
   -v /usr/bin/docker-runc:/usr/bin/docker-runc     \
   -v /usr/lib/systemd:/usr/lib/systemd     \
   -v /var/lib:/var/lib     \
   -v /var/run/docker.sock:/var/run/docker.sock     \
   --label docker_bench_security     \
   docker/docker-bench-security -i "nuvlabox_" -e 1,2,3,7