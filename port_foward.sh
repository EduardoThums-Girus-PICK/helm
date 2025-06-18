#!/bin/bash

# Configuração
NAMESPACE=${1:-"girus"}
SERVICE_NAME=girus-frontend
LOCAL_PORT=8000
REMOTE_PORT=8080
MAX_RETRIES=5
HEALTH_CHECK_INTERVAL=5  # segundos
HEALTH_CHECK_TIMEOUT=2   # tempo limite do curl em segundos

# Função para verificar se a porta local está respondendo
check_health() {
    curl --silent --max-time $HEALTH_CHECK_TIMEOUT "http://localhost:$LOCAL_PORT" > /dev/null
    return $?
}

# Função para iniciar o port-forward com kubectl
start_port_forward() {
    echo -e "🚀 Iniciando o port-forward para o serviço 👉 \033[1m$SERVICE_NAME\033[0m no namespace \033[1m$NAMESPACE\033[0m..."
    kubectl port-forward svc/$SERVICE_NAME $LOCAL_PORT:$REMOTE_PORT -n $NAMESPACE &
    PF_PID=$!
}

# Loop de tentativas
retry_count=0

while [ $retry_count -lt $MAX_RETRIES ]; do
    start_port_forward

    echo "⏳ Aguardando o processo de port-forward (PID $PF_PID) ficar saudável..."
    sleep 2

    echo -e "🌐 Acesse a aplicação em: \033[1mhttp://localhost:$LOCAL_PORT\033[0m"

    while kill -0 $PF_PID 2>/dev/null; do
        if check_health; then
            echo "✅ Verificação de saúde bem-sucedida. Serviço está acessível."
            sleep $HEALTH_CHECK_INTERVAL
        else
            echo "❌ Verificação de saúde falhou! Reiniciando o port-forward..."
            kill $PF_PID
            wait $PF_PID 2>/dev/null
            break
        fi
    done

    echo -e "🔁 O processo de port-forward foi interrompido ou falhou. Tentativa número $((retry_count + 1)) de $MAX_RETRIES..."
    retry_count=$((retry_count + 1))
    sleep $retry_count  # Atraso incremental
done

echo -e "\n💥 \033[1;31mErro:\033[0m Não foi possível manter o port-forward ativo após $MAX_RETRIES tentativas."
exit 1
