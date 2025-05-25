<!-- helm repo add teste --username EduardoThums --password $GITHUB_TOKEN https://raw.githubusercontent.com/EduardoThums-Girus-PICK/helm/gh-pages -->

kubectl -n girus create secret generic regcred \
    --from-file=.dockerconfigjson=$HOME/.docker/config.json \
    --type=kubernetes.io/dockerconfigjson

echo $GITHUB_TOKEN | helm registry login ghcr.io -u EduardoThums --password-stdin
helm upgrade -i -n girus teste oci://ghcr.io/eduardothums-girus-pick/helm/charts/girus --version 0.1.7
