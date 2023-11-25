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

# Function to transfer files
transfer_files() {
    echo "Transferring files to VM..."

    # Transfer the docker-compose file
    if ! gcloud compute scp "$LOCAL_DOCKER_COMPOSE_PATH" "$VM_NAME":; then
        echo "Failed to transfer docker-compose file. Exiting..."
        exit 1
    fi

    # Transfer the .env file
    if ! gcloud compute scp "$LOCAL_PROD_ENV_PATH" "$VM_NAME":.env; then
        echo "Failed to transfer .env file. Exiting..."
        exit 1
    fi

    # Transfer the servers.json file
    if ! gcloud compute scp "$LOCAL_SERVERS_JSON_PATH" "$VM_NAME":; then
        echo "Failed to transfer servers.json file. Exiting..."
        exit 1
    fi

    # Transfer the Google credentials file
    if ! gcloud compute scp "$GOOGLE_CREDENTIALS_PATH" "$VM_NAME":gcp_credentials.json; then
        echo "Failed to transfer Google credentials file. Exiting..."
        exit 1
    fi
}

# Main script execution
check_vm_status
transfer_files

echo "Files have been successfully transferred to VM."