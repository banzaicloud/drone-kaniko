FROM gcr.io/kaniko-project/executor:debug-v0.22.0

ENV HOME /root
ENV USER root
ENV SSL_CERT_DIR=/kaniko/ssl/certs
ENV DOCKER_CONFIG /kaniko/.docker/
ENV DOCKER_CREDENTIAL_GCR_CONFIG /kaniko/.config/gcloud/docker_credential_gcr_config.json

# add the wrapper which acts as a drone plugin
COPY plugin.sh /kaniko/plugin.sh
ENTRYPOINT [ "/kaniko/plugin.sh" ]
