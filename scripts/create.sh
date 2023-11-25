#!/bin/bash

# Get the directory of the current script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Get the parent directory of the script
PARENT_DIR="$(dirname "$DIR")"

# Automatically export all variables from the .env file in the parent directory
set -a
source "$PARENT_DIR/.env"
set +a

# Function to check if VM already exists
check_vm_existence() {
    if gcloud compute instances describe "$VM_NAME" > /dev/null 2>&1; then
        echo "VM $VM_NAME already exists. Exiting..."
        exit 1
    fi
}

# Function to create VM
create_vm() {
    echo "Creating VM instance..."
    if ! gcloud compute instances create "$VM_NAME" \
        --machine-type="$MACHINE_TYPE" \
        --boot-disk-size="$BOOT_DISK_SIZE" \
        --tags=http-server,https-server; then
        echo "Failed to create VM. Exiting..."
        exit 1
    fi
}

# Function to install Docker on VM
install_docker() {
    echo "Installing Docker on the VM..."
    if ! gcloud compute ssh "$VM_NAME" --command='
        sudo apt-get update
        sudo apt-get install -y ca-certificates curl gnupg lsb-release
        sudo mkdir -p /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt-get update
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
        sudo usermod -aG docker $USER
    '; then
        echo "Failed to install Docker. Exiting..."
        exit 1
    fi
}

# Main script execution
check_vm_existence
create_vm
install_docker

echo "VM creation and Docker installation completed successfully."