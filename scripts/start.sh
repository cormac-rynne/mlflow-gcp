#!/bin/bash

# Get the directory of the current script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Get the parent directory of the script
PARENT_DIR="$(dirname "$DIR")"

# Automatically export all variables from the .env file in the parent directory
set -a
source "$PARENT_DIR/.env"
set +a

TIMEOUT=30 # 30 seconds timeout

# Function to get VM status
get_vm_status() {
    gcloud compute instances describe "$VM_NAME" --format='get(status)'
}

# Function to start the VM
start_vm() {
    VM_STATUS=$(get_vm_status)
    echo "Initial VM Status for $VM_NAME: $VM_STATUS"

    if [[ "$VM_STATUS" != "RUNNING" ]]; then
        echo "Starting VM..."
        if ! gcloud compute instances start "$VM_NAME"; then
            echo "Failed to start VM. Exiting..."
            exit 1
        fi

        # Wait for VM to be in RUNNING state
        local counter=0
        while [[ "$VM_STATUS" != "RUNNING" && $counter -lt $TIMEOUT ]]; do
            sleep 3
            VM_STATUS=$(get_vm_status)
            echo "Current VM Status: $VM_STATUS"
            ((counter+=3))
        done

        if [[ "$VM_STATUS" != "RUNNING" ]]; then
            echo "Timeout reached. VM failed to start. Exiting..."
            exit 1
        fi
    fi

    echo "VM is now running."
}

# Function to run Docker Compose
run_docker_compose() {
    "$DIR/up.sh"
}

# Main script execution
start_vm
run_docker_compose

echo "VM started and Docker Compose has been successfully executed."
