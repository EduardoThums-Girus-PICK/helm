#!/bin/bash

# Configuration
NAMESPACE=${1:-"girus"}
SERVICE_NAME=girus-frontend
LOCAL_PORT=8000
REMOTE_PORT=8080
MAX_RETRIES=5
HEALTH_CHECK_INTERVAL=5  # seconds
HEALTH_CHECK_TIMEOUT=2   # curl timeout in seconds

# Function to check if the local port is responding
check_health() {
    curl --silent --max-time $HEALTH_CHECK_TIMEOUT "http://localhost:$LOCAL_PORT" > /dev/null
    return $?
}

# Function to start kubectl port-forward
start_port_forward() {
    echo "Starting port-forward to service/$SERVICE_NAME..."
    kubectl port-forward svc/$SERVICE_NAME $LOCAL_PORT:$REMOTE_PORT -n $NAMESPACE &
    PF_PID=$!
}

# Retry loop
retry_count=0

while [ $retry_count -lt $MAX_RETRIES ]; do
    start_port_forward

    echo "Waiting for port-forward process (PID $PF_PID) to become healthy..."
    sleep 2

    while kill -0 $PF_PID 2>/dev/null; do
        if check_health; then
            sleep $HEALTH_CHECK_INTERVAL
        else
            echo "Health check failed. Restarting port-forward..."
            kill $PF_PID
            wait $PF_PID 2>/dev/null
            break
        fi
    done

    echo "Port-forward process stopped or failed. Retrying..."
    retry_count=$((retry_count + 1))
    sleep $retry_count  # Increasing delay
done

echo "Failed to keep port-forward alive after $MAX_RETRIES attempts."
exit 1
