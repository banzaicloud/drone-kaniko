# kaniko-plugin

A thin shim-wrapper around the official [Google Kaniko](https://cloud.google.com/blog/products/gcp/introducing-kaniko-build-container-images-in-kubernetes-and-google-container-builder-even-without-root-access) Docker image to make it behave like the [Drone Docker plugin](http://plugins.drone.io/drone-plugins/drone-docker/).

## Test that it can build itself

```bash
docker run -it --rm -w /src -v $PWD:/src -e DOCKER_USERNAME=${DOCKER_USERNAME} -e DOCKER_PASSWORD=${DOCKER_PASSWORD} -e PLUGIN_REPO=banzaicloud/kaniko-plugin -e PLUGIN_TAGS=test -e PLUGIN_DOCKERFILE=Dockerfile.test banzaicloud/kaniko-plugin
```
