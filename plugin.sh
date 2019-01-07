#!/bin/sh

set -euo pipefail

export PATH=$PATH:/kaniko/

if [[ -n "${PLUGIN_USERNAME}" ]]; then
    DOCKER_AUTH=`echo -n "${PLUGIN_USERNAME}:${PLUGIN_PASSWORD}" | base64`

    REGISTRY=${PLUGIN_REGISTRY:-https://index.docker.io/v1/}

    cat > /kaniko/.docker/config.json <<DOCKERJSON
{
    "auths": {
        "${REGISTRY}": {
            "auth": "${DOCKER_AUTH}"
        }
    }
}
DOCKERJSON
fi

DOCKERFILE=${PLUGIN_DOCKERFILE:-Dockerfile}
DESTINATION=${PLUGIN_REPO}:${PLUGIN_TAGS:-latest}
CONTEXT=${PLUGIN_CONTEXT:-$PWD}
LOG=${PLUGIN_LOG:-info}
BUILD_ARGS=`echo ${PLUGIN_BUILD_ARGS:-} | jq -r 'map("--build-arg " + .) | join(" ")'`

/kaniko/executor -v ${LOG} \
    --context ${CONTEXT} \
    --dockerfile ${DOCKERFILE} \
    --destination ${DESTINATION} \
    ${BUILD_ARGS}
