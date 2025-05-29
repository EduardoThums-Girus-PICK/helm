# Repositório Helm Girus

Este projeto serve como repositório Helm para os charts da aplicação Girus. Para saber mais o que é o Girus leia [aqui](https://linuxtips.io/girus-labs/).

## Como utilizar

<!-- helm repo add teste --username EduardoThums --password $GITHUB_TOKEN https://raw.githubusercontent.com/EduardoThums-Girus-PICK/helm/gh-pages -->

```bash
kubectl -n girus create secret generic regcred \
    --from-file=.dockerconfigjson=$HOME/.docker/config.json \
    --type=kubernetes.io/dockerconfigjson

echo $GITHUB_TOKEN | helm registry login ghcr.io -u EduardoThums --password-stdin
helm upgrade -i -n girus teste oci://ghcr.io/eduardothums-girus-pick/helm/charts/girus --version 0.1.7

# or

curl -LJ https://github.com/EduardoThums-Girus-PICK/helm/releases/latest/download/manifest.yaml | kubectl apply -f -

# or
git clone
cd
helm install girus charts/girus --set deployment.imagePullSecretsName=regcred -n girus

./port_foward.sh girus
```
