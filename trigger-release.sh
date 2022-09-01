#!/bin/sh

set -o pipefail

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
if [ "$branch" != "main" ]
then
  echo "ERR: this script can only be executed on the main branch"
  exit 1
fi

set -x

git tag -l "$tag" | grep "$tag"

if [ $? -eq 0 ]
then
  echo "ERR: chosen version $tag already exists"
  exit 1
fi

sed -i.old "s/NUVLAEDGE_ENGINE_VERSION.*/NUVLAEDGE_ENGINE_VERSION=$tag/g" docker-compose.yml
rm docker-compose.yml.old

#sed -i.old "s/DOCKER_IMAGE=.*/DOCKER_IMAGE=$tag/g" nuvlaedge-engine-installer/container-release.sh
#rm nuvlaedge-engine-installer/container-release.sh.old

git add docker-compose.yml #nuvlaedge-engine-installer/container-release.sh
git commit -m "Update NuvlaEdge Engine version to $tag"
git push

git tag -a $tag -m "Triggering automatic release for NuvlaEdge Engine - $tag"
git push origin $tag

set +x
echo "SUCCESS: please check the repository's action to follow the release process. A release notification will be sent to you soon"
