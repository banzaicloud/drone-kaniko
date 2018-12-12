FROM gcr.io/kaniko-project/executor:v0.7.0 AS kaniko

FROM alpine:3.8

# clone the official kaniko container into this one, env vars needs to be re-set
COPY --from=kaniko / /
ENV HOME /root
ENV USER /root
ENV SSL_CERT_DIR=/kaniko/ssl/certs
ENV DOCKER_CONFIG /kaniko/.docker/
ENV DOCKER_CREDENTIAL_GCR_CONFIG /kaniko/.config/gcloud/docker_credential_gcr_config.json

RUN apk add --update --no-cache jq

# add the wrapper which acts as a drone plugin
COPY plugin.sh /usr/bin/
ENTRYPOINT [ "/usr/bin/plugin.sh" ]
