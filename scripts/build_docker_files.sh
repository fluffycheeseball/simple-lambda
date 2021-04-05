#!/usr/bin/env bash
set -e

# build_image <image name> <dockerfile>
# build a Docker image
function build_image() {
  image_name=$1
  dockerfile=$2

  if [ -z "${dockerfile}" ]; then
    dockerfile=Dockerfile
  fi

  buildname="${image_name}:ci-${CIRCLE_SHA1}"

  echo "Building ${buildname}"
  docker build -t ${buildname} -f ./${dockerfile} .
}

# build primary image (project name)
build_image ${CIRCLE_PROJECT_REPONAME}

echo ${CIRCLE_PROJECT_REPONAME} > /tmp/image.names

# build any additional images specified in Dockerfile.<image>
if [ -f Dockerfile.* ]; then
  for dockerfile in Dockerfile.*; do
    # parse the file and extract the image name to use in the buildname ?
    image_sfx=$(echo ${dockerfile} | sed -e s/^.*Dockerfile\.//)
    build_image ${CIRCLE_PROJECT_REPONAME}-${image_sfx} ${dockerfile}
    echo ${CIRCLE_PROJECT_REPONAME}-${image_sfx} >> /tmp/image.names
  done
fi

exit 0

