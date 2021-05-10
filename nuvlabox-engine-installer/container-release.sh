#!/bin/bash -xe


DOCKER_IMAGE=installer

# default env vars in GH actions
GIT_BRANCH=$(echo ${GITHUB_REF} | awk -F'/' '{print $(NF)}' | sed -e 's/[^a-z0-9\._-]/-/g')

if [[ "${GIT_BRANCH}" != "master" ]] || [[ "${GIT_BRANCH}" != *"."*"."* ]]
then
  DOCKER_ORG=nuvladev
else
  DOCKER_ORG=nuvlabox
fi

MANIFEST=${DOCKER_ORG}/${DOCKER_IMAGE}:${GIT_BRANCH}

platforms=(amd64 arm64 arm)

#
# remove any previous builds
#

rm -Rf target/*.tar
mkdir -p target
cp ../docker-compose.* target/

#
# generate image for each platform
#

for platform in "${platforms[@]}"; do
    docker run --rm --privileged -v ${PWD}:/tmp/work --entrypoint buildctl-daemonless.sh moby/buildkit:master \
           build \
           --frontend dockerfile.v0 \
           --opt platform=linux/${platform} \
           --opt filename=./Dockerfile \
           --opt build-arg:GIT_BRANCH=${GIT_BRANCH} \
           --opt build-arg:GIT_BUILD_TIME=${GIT_BUILD_TIME} \
           --opt build-arg:GIT_COMMIT_ID=${GITHUB_SHA} \
           --opt build-arg:GITHUB_RUN_NUMBER=${GITHUB_RUN_NUMBER} \
           --opt build-arg:GITHUB_RUN_ID=${GITHUB_RUN_ID} \
           --output type=docker,name=${MANIFEST}-${platform},dest=/tmp/work/target/${DOCKER_IMAGE}-${platform}.docker.tar \
           --local context=/tmp/work \
           --local dockerfile=/tmp/work \
           --progress plain

done

#
# load all generated images
#

for platform in "${platforms[@]}"; do
    docker load --input ./target/${DOCKER_IMAGE}-${platform}.docker.tar
done


manifest_args=(${MANIFEST})

#
# login to docker hub
#

unset HISTFILE
echo ${DOCKER_PASSWORD} | docker login -u ${DOCKER_USERNAME} --password-stdin

#
# push all generated images
#

for platform in "${platforms[@]}"; do
    docker push ${MANIFEST}-${platform}
    manifest_args+=("${MANIFEST}-${platform}")    
done

#
# create manifest, update, and push
#

export DOCKER_CLI_EXPERIMENTAL=enabled
docker manifest create "${manifest_args[@]}"

for platform in "${platforms[@]}"; do
    docker manifest annotate ${MANIFEST} ${MANIFEST}-${platform} --arch ${platform}
done

docker manifest push --purge ${MANIFEST}
