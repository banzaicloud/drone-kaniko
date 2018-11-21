#!/bin/sh

set -euo pipefail

export PATH=$PATH:/kaniko/

DOCKER_AUTH=`echo -n "${DOCKER_USERNAME}:${DOCKER_PASSWORD}" | base64`

cat > /kaniko/.docker/config.json <<DOCKERJSON
{
    "auths": {
        "https://index.docker.io/v1/": {
            "auth": "${DOCKER_AUTH}"
        }
    }
}
DOCKERJSON

DOCKERFILE=${PLUGIN_DOCKERFILE:-Dockerfile}
DESTINATION=${PLUGIN_REPO}:${PLUGIN_TAGS:-latest}
CONTEXT=${PLUGIN_CONTEXT:-$PWD}
LOG=${PLUGIN_LOG:-info}

/kaniko/executor -v ${LOG} \
    --context ${CONTEXT} \
    --dockerfile ${DOCKERFILE} \
    --destination ${DESTINATION}
