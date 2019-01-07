#!/busybox/sh

set -euo pipefail

export PATH=$PATH:/kaniko/

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

DOCKERFILE=${PLUGIN_DOCKERFILE:-Dockerfile}
DESTINATION=${PLUGIN_REPO}:${PLUGIN_TAGS:-latest}
CONTEXT=${PLUGIN_CONTEXT:-$PWD}
LOG=${PLUGIN_LOG:-info}
case "${PLUGIN_CACHE:-}" in
  true) CACHE="true" ;;
     *) CACHE="false" ;;
esac

if [[ -n "${PLUGIN_BUILD_ARGS:-}" ]]; then
    BUILD_ARGS=$(echo "${PLUGIN_BUILD_ARGS}" | tr ',' '\n' | while read build_arg; do echo "--build-arg=${build_arg}"; done)
fi

/kaniko/executor -v ${LOG} \
    --context=${CONTEXT} \
    --dockerfile=${DOCKERFILE} \
    --destination=${DESTINATION} \
    --cache=${CACHE} \
    ${BUILD_ARGS:-}
