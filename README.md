<!-- helm repo add teste --username EduardoThums --password $GITHUB_TOKEN https://raw.githubusercontent.com/EduardoThums-Girus-PICK/helm/gh-pages -->

kubectl -n girus create secret generic regcred \
    --from-file=.dockerconfigjson=$HOME/.docker/config.json \
    --type=kubernetes.io/dockerconfigjson

helm install -n girus teste oci://ghcr.io/eduardothums-girus-pick/helm/charts/girus
