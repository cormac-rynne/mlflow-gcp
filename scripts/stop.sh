#!/bin/bash

# Get the directory of the current script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Get the parent directory of the script
PARENT_DIR="$(dirname "$DIR")"

# Automatically export all variables from the .env file in the parent directory
set -a
source "$PARENT_DIR/.env"
set +a

# Shut down the VM
echo "Shutting down VM $VM_NAME..."
gcloud compute instances stop "$VM_NAME"

echo "VM $VM_NAME has been successfully shut down."