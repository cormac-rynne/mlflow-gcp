#!/bin/bash

# Get the directory of the current script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Get the parent directory of the script
PARENT_DIR="$(dirname "$DIR")"

# Automatically export all variables from the .env file in the parent directory
set -a
source "$PARENT_DIR/.env"
set +a

# Function to check VM status
check_vm_status() {
    if ! gcloud compute instances describe "$VM_NAME" --format='get(status)' | grep -q "RUNNING"; then
        echo "VM $VM_NAME is not running or does not exist. Exiting..."
        exit 1
    fi
}

# Function to run Docker Compose on the VM
run_docker_compose() {
    echo "Running Docker Compose up on the VM..."
    if ! gcloud compute ssh "$VM_NAME" --command='
        docker compose up -d
    '; then
        echo "Failed to run Docker Compose. Exiting..."
        exit 1
    fi
}

get_vm_ip_address() {
    # Find your public IP address
    # Get the external IP address of the VM
    VM_IP=$(gcloud compute instances describe "$VM_NAME" \
        --format='get(networkInterfaces[0].accessConfigs[0].natIP)')
}

# Main script execution
check_vm_status
run_docker_compose
get_vm_ip_address

echo "Docker Compose has been successfully started on the VM."
echo "The external IP address of the VM is: $VM_IP"
echo "MLFlow: http://$VM_IP:8000"
echo "PgAdmin: http://$VM_IP:5000"