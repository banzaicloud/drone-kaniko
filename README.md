# drone-kaniko

A thin shim-wrapper around the official [Google Kaniko](https://cloud.google.com/blog/products/gcp/introducing-kaniko-build-container-images-in-kubernetes-and-google-container-builder-even-without-root-access) Docker image to make it behave like the [Drone Docker plugin](http://plugins.drone.io/drone-plugins/drone-docker/).

Example .drone.yml for Drone 1.0 (pushing to Docker Hub):

```yaml
kind: pipeline
name: default

steps:
- name: publish
  image: banzaicloud/drone-kaniko
  settings:
    registry: registry.example.com
    repo: registry.example.com/example-project
    tags: ${DRONE_COMMIT_SHA}
    cache: true
    build_args:
    - COMMIT_SHA=${DRONE_COMMIT_SHA}
    - COMMIT_AUTHOR_EMAIL=${DRONE_COMMIT_AUTHOR_EMAIL}
    username:
      from_secret: docker-username
    password:
      from_secret: docker-password
```

Pushing to GCR:

```yaml
kind: pipeline
name: default

steps:
- name: publish
  image: banzaicloud/drone-kaniko
  settings:
    repo: gcr.io/example.com/example-project
    tags: ${DRONE_COMMIT_SHA}
    cache: true
    google_application_credentials:
      from_secret: google-application-credentials
```

## Test that it can build

```bash
docker run -it --rm -w /src -v $PWD:/src -e PLUGIN_USERNAME=${DOCKER_USERNAME} -e PLUGIN_PASSWORD=${DOCKER_PASSWORD} -e PLUGIN_REPO=banzaicloud/drone-kaniko-test -e PLUGIN_TAGS=test -e PLUGIN_DOCKERFILE=Dockerfile.test banzaicloud/drone-kaniko
```

## Test that caching works

Start a Docker registry at 127.0.0.1:5000:

```bash
docker run -d -p 5000:5000 --restart always --name registry --hostname registry.local registry:2
```

Add the following lines to plugin.sh's final command and build a new image from it:

```diff
+    --cache=true \
+    --cache-repo=127.0.0.1:5000/${PLUGIN_REPO} \
```

```bash
docker build -t banzaicloud/drone-kaniko .
```


Warm up the alpine image to the cache:

```bash
docker run -v $PWD:/cache gcr.io/kaniko-project/warmer:latest --verbosity=debug --image=alpine:3.8
```


Run the builder (on the host network to be able to access the registry, if any specified) with mounting the local disk cache, this example pushes to Docker Hub:

```bash
docker run --net=host -it --rm -w /src -v $PWD:/cache -v $PWD:/src -e PLUGIN_USERNAME=${DOCKER_USERNAME} -e PLUGIN_PASSWORD=${DOCKER_PASSWORD} -e PLUGIN_REPO=banzaicloud/drone-kaniko-test -e PLUGIN_TAGS=test -e PLUGIN_DOCKERFILE=Dockerfile.test -e PLUGIN_CACHE=true banzaicloud/drone-kaniko
```

The very same example just pushing to GCR instead of Docker Hub:

```bash
docker run --net=host -it --rm -w /src -v $PWD:/cache -v $PWD:/src -e PLUGIN_REPO=gcr.io/banzaicloud/drone-kaniko-test -e PLUGIN_TAGS=test -e PLUGIN_DOCKERFILE=Dockerfile.test -e PLUGIN_CACHE=true -e PLUGIN_GOOGLE_APPLICATION_CREDENTIALS="$(<$HOME/google-application-credentials.json)" banzaicloud/drone-kaniko
```
