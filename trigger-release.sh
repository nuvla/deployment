#!/bin/sh

tag=$1

usage="\nUSAGE:\n
./trigger-release.sh VERSION
\n\n
\tVERSION\t\tSemantic tag number
"

if [ -z $tag ]
then
  echo "ERR: missing tag version"
  echo $usage
  exit 1
fi

branch=$(git rev-parse --abbrev-ref HEAD)
if [ "$branch" != "master" ]
then
  echo "ERR: this script can only be executed on the master branch"
  exit 1
fi

set -x

git tag -l "$tag" | grep "$tag"

if [ $? -eq 0 ]
then
  echo "ERR: chosen version $tag already exists"
  exit 1
fi

sed -i.old "s/NUVLABOX_ENGINE_VERSION.*/NUVLABOX_ENGINE_VERSION=$tag/g" docker-compose.yml
rm docker-compose.yml.old

sed -i.old "s/DOCKER_IMAGE=.*/DOCKER_IMAGE=$tag/g" nuvlabox-engine-installer/container-release.sh
rm nuvlabox-engine-installer/container-release.sh.old

git add docker-compose.yml nuvlabox-engine-installer/container-release.sh.old
git commit -m "Update NuvlaBox Engine version to $tag"
git push

git tag -a $tag -m "Triggering automatic release for NuvlaBox Engine - $tag"
git push origin $tag

set +x
echo "SUCCESS: please check the repository's action to follow the release process. A release notification will be sent to you soon"