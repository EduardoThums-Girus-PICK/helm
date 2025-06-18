# 📦 Repositório Helm Girus

Este repositório serve como um repositório Helm público para a aplicação [Girus](https://linuxtips.io/girus-labs/), hospedando charts que são automaticamente empacotados e versionados através da GitHub Action [`helm/chart-releaser-action`](https://github.com/helm/chart-releaser-action).

A cada nova release, os charts são publicados automaticamente na seção de GitHub Releases, e os pacotes `.tgz` e `index.yaml` são atualizados na branch `gh-pages`, tornando este repositório compatível com o Helm como repositório de charts.

## 🧭 Como utilizar

Para utilizar este repositório Helm é necessário os seguintes pré-requisitos

1. Helm instalado
2. Kubectl instalado
3. Cluster kubernetes rodando

### ⚙️ Criando um cluster kubernetes com kind

Para fins educativos vamos utilizar a ferramenta kind (kubernetes-in-docker) que faz o use de containers docker para criar um cluster kubernetes de forma local. Instale a ferramenta kind de acordo com a [documentação oficial](https://kind.sigs.k8s.io/#installation-and-usage) e seguia a instruções abaixo:

1. Crie o cluster kind

```bash
cat <<EOF | kind create cluster --config -
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
    image: kindest/node:v1.32.5@sha256:e3b2327e3a5ab8c76f5ece68936e4cafaa82edf58486b769727ab0b3b97a5b0d
EOF
```

2. Verifique os nós estão funcionando corretamente

```bash
kubectl wait --for=condition=Ready nodes --all --timeout=60s
```

### 📥 Instalando via helm através do repositório (recomendado)

1. Adicione o repositório helm

```bash
helm repo add girus https://EduardoThums-Girus-PICK.github.io/helm
```

2. Instale o chart

```bash
helm install -n girus --create-namespace girus girus/girus
```

3. Aguarde até que todos os serviços estejam executando corretamente

```bash
kubectl -n girus wait pod --all --for=condition=Ready -l app.kubernetes.io/part-of=girus --timeout 60s
```

4. Execute o script `port_foward.sh` que ira abrir a porta 8000 para acessar a aplicação do frontend

```bash
./port_foward.sh
```

5. Acesse o endereço da aplicação em http://localhost:8000

### 📦 Instalando via kubectl

1. Crie o namespace `girus`

```bash
kubectl create namespace girus
```

2. Execute o comando `kubectl apply` apontando para o manifesto gerado na ultima release

```bash
curl -LJ https://github.com/EduardoThums-Girus-PICK/helm/releases/latest/download/manifest.yaml | kubectl apply -f -
```

3. Aguarde até que todos os serviços estejam executando corretamente

```bash
kubectl -n girus wait pod --all --for=condition=Ready -l app.kubernetes.io/part-of=girus --timeout 60s
```

5. Execute o script `port_foward.sh` que ira abrir a porta 8000 para acessar a aplicação do frontend

```bash
./port_foward.sh
```

6. Acesse o endereço da aplicação em http://localhost:8000


### 💻 Instalando via helm através do código fonte

1. Clone o repositório do git

```bash
git clone https://github.com/EduardoThums-Girus-PICK/helm.git girus-helm
cd girus-helm
```

2. Instale o chart

```bash
helm install -n girus --create-namespace girus ./charts/girus
```

3. Aguarde até que todos os serviços estejam executando corretamente

```bash
kubectl -n girus wait pod --all --for=condition=Ready -l app.kubernetes.io/part-of=girus --timeout 60s
```

4. Execute o script `port_foward.sh` que ira abrir a porta 8000 para acessar a aplicação do frontend

```bash
./port_foward.sh
```

5. Acesse o endereço da aplicação em http://localhost:8000

## ⚙️ Configurações do chart através dos values

Para configurar certos aspectos do chart como qual imagem utilizar no backend, quantidade de replicas, se tem possui integração com Ingress NGINX Controller, etc é preciso fornecer parametros na instalação/atualização, todos os parametros podem ser encontrados no arquivo [values.yaml](./charts/girus/values.yaml). Abaixo a explicação de cada parametro:

### 🗂️ Nome do namespace

Por padrão o chart será instalado no namespace fornecido no comando do helm, porém isso pode ser alterado através do parametro `namespaceOverride`.

**Via arquivo:**

```bash
cat <<EOF | helm upgrade -i girus girus/girus --values -
namespaceOverride: "meu-namespace"
EOF
```

**Via linha de comando:**

```bash
helm upgrade -i girus girus/girus --set namespaceOverride=meu-namespace
```

### 🏷️ Label a qual os recursos fazem parte

Para customizar a label `app.kubernetes.io/part-of` que especifica de qual sistema os recursos fazem parte é só alterar o valo do parametro `label.partOf`.

**Via arquivo:**

```bash
cat <<EOF | helm upgrade -i girus girus/girus --values -
label:
  partOf: meu-sistema
EOF
```

**Via linha de comando:**

```bash
helm upgrade -i girus girus/girus --set label.partOf=meu-sistema
```

### 🚀 Deployment

É possível customizar a imagem, quantidade de replicas e porta do container dos deployments do frontend e backend através do parametro `deployment.<backend|frontend>.<image|replicas|containerPort>`

**Via arquivo:**

```bash
cat <<EOF | helm upgrade -i girus girus/girus --values -
deployment:
  backend:
    image: eduardothums/girus:backend-v1.0.2
    containerPort: 8081
    replicas: 1
  frontend:
    image: eduardothums/girus:frontend-v1.0.7
    containerPort: 8000
    replicas: 2
EOF
```

**Via linha de comando:**

```bash
helm upgrade -i girus girus/girus \
  --set deployment.backend.image=eduardothums/girus:backend-v1.0.2
  --set deployment.frontend.image=eduardothums/girus:frontend-v1.0.7
```

### 🌐 Ingress

Ao invés de expor a aplicação do frontend através do comando `kubectl port-foward` é possivel expo-lá pelo Ingress NGINX Controller apenas habilitando a sua configuração através do parametro `ingress.enabled`.

> ⚠️ Se você estiver utilizando o kind para subir o cluster kubernetes então deve seguir as instruções na documentação oficial para configurar o [ingress](https://kind.sigs.k8s.io/docs/user/ingress). Abaixo um exemplo alterando cluster criado com o kind anteriormente na documentação:

1. Delete o cluster kind

```bash
kind delete clusters kind
```

2. Crie o cluster kind com as configurações especificas para utilizar um ingress

```bash
cat <<EOF | kind create cluster --config -
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
    image: kindest/node:v1.32.5@sha256:e3b2327e3a5ab8c76f5ece68936e4cafaa82edf58486b769727ab0b3b97a5b0d
    labels:
      ingress-ready: true
    extraPortMappings:
    - containerPort: 80
      hostPort: 80
      protocol: TCP
      listenAddress: 127.0.0.1
    - containerPort: 443
      hostPort: 443
      protocol: TCP
      listenAddress: 127.0.0.1
EOF
```

3. Verifique os nós estão funcionando corretamente

```bash
kubectl wait --for=condition=Ready nodes --all --timeout=60s
```

4. instale o Ingress NGINX Controller

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/refs/heads/main/deploy/static/provider/kind/deploy.yaml
```

5. Aguarde até que todos os serviços estejam rodando

```bash
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s
```

6. Instale o chart girus

```bash
helm install -n girus --create-namespace girus girus/girus --set ingress.enabled=true
```

7. Aguarde até que todos os serviços estejam executando corretamente

```bash
kubectl -n girus wait pod --all --for=condition=Ready -l app.kubernetes.io/part-of=girus --timeout 60s
```

8. Verifique que o ingress foi criado no namespace girus

```bash
kubectl -n girus get ingress
```

9. Accesse a aplicação através do endereço http://localhost

---
**Via arquivo:**

```bash
cat <<EOF | helm upgrade -i girus girus/girus --values -
ingress:
  enabled: true
EOF
```

**Via linha de comando:**

```bash
helm upgrade -i girus girus/girus --set ingress.enabled=true
```

## 🔁 Fluxo do CI/CD

Utilizamos o GitHub Actions como plataforma de CI/CD do projeto, onde é realizado validações de segurança, boas práticas, build de imagems e publicações de releases através de tags do git.

Existem dois momentos onde os workflows definidos em `./github/workflows` são disparados:

1. `security_check.yaml`: quando há algum pull request aberto com a branch target apontando para a `main`
2. `release.yaml`: quando uma tag é criada no repositório

### 🛡️ security_check.yaml

Este workflow tem como objetivo:

1. Aplicar validações de segurança no código afim de encontrar vulnerabilidades através da ferramenta [Trivy](https://trivy.dev/latest/)

2. Aplicar validações de boas práticas na criação dos charts através do [helm lint](https://helm.sh/docs/helm/helm_lint/)

### 🚀 release.yaml

Este workflow tem como objetivo:

1. Aplicar todas as etapas realizadas no workflow `security_check.yaml` para garantir que nenhuma vulnerabilidade veio a surgir entre o tempo de merge do pull request e a geração da tag

2. Gerar uma release no github que irá servir como repositório helm para os charts

3. Gerar um manifesto com todos os templates do chart e publicar na release criada anteriormente

