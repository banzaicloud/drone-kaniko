#!/busybox/sh

set -euo pipefail

export PATH=$PATH:/kaniko/

REGISTRY=${PLUGIN_REGISTRY:-index.docker.io}

if [ "${PLUGIN_USERNAME:-}" ] || [ "${PLUGIN_PASSWORD:-}" ]; then
    DOCKER_AUTH=`echo -n "${PLUGIN_USERNAME}:${PLUGIN_PASSWORD}" | base64 | tr -d "\n"`

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

if [ "${PLUGIN_JSON_KEY:-}" ];then
    echo "${PLUGIN_JSON_KEY}" > /kaniko/gcr.json
    export GOOGLE_APPLICATION_CREDENTIALS=/kaniko/gcr.json
fi

DOCKERFILE=${PLUGIN_DOCKERFILE:-Dockerfile}
CONTEXT=${PLUGIN_CONTEXT:-$PWD}
LOG=${PLUGIN_LOG:-info}
EXTRA_OPTS=""

if [[ -n "${PLUGIN_TARGET:-}" ]]; then
    TARGET="--target=${PLUGIN_TARGET}"
fi

if [[ "${PLUGIN_SKIP_TLS_VERIFY:-}" == "true" ]]; then
    EXTRA_OPTS="--skip-tls-verify=true"
fi

if [[ "${PLUGIN_CACHE:-}" == "true" ]]; then
    CACHE="--cache=true"
fi

if [ -n "${PLUGIN_BUILD_ARGS:-}" ]; then
    BUILD_ARGS=$(echo "${PLUGIN_BUILD_ARGS}" | tr ',' '\n' | while read build_arg; do echo "--build-arg=${build_arg}"; done)
fi

if [ -n "${PLUGIN_BUILD_ARGS_FROM_ENV:-}" ]; then
    BUILD_ARGS_FROM_ENV=$(echo "${PLUGIN_BUILD_ARGS_FROM_ENV}" | tr ',' '\n' | while read build_arg; do echo "--build-arg ${build_arg}=$(eval "echo \$$build_arg")"; done)
fi

if [ -n "${PLUGIN_TAGS:-}" ]; then
    DESTINATIONS=$(echo "${PLUGIN_TAGS}" | tr ',' '\n' | while read tag; do echo "--destination=${REGISTRY}/${PLUGIN_REPO}:${tag} "; done)
elif [ -f .tags ]; then
    DESTINATIONS=$(cat .tags| tr ',' '\n' | while read tag; do echo "--destination=${REGISTRY}/${PLUGIN_REPO}:${tag} "; done)
elif [ -n "${PLUGIN_REPO:-}" ]; then
    DESTINATIONS="--destination=${PLUGIN_REPO}:latest"
else
    DESTINATIONS="--no-push"
    # Cache is not valid with --no-push
    CACHE=""
fi

/kaniko/executor -v ${LOG} \
    --context=${CONTEXT} \
    --dockerfile=${DOCKERFILE} \
    ${EXTRA_OPTS} \
    ${DESTINATIONS} \
    ${CACHE:-} \
    ${TARGET:-} \
    ${BUILD_ARGS:-} \
    ${BUILD_ARGS_FROM_ENV:-}
