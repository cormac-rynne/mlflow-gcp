#!/bin/bash

# Environment Variables
# Get the directory of the current script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Get the parent directory of the script
PARENT_DIR="$(dirname "$DIR")"

# Automatically export all variables from the .env file in the parent directory
set -a
source "$PARENT_DIR/.env"
set +a

# Function to check if the VM exists
check_vm_existence() {
    if gcloud compute instances describe "$VM_NAME" > /dev/null 2>&1; then
        echo "VM $VM_NAME exists."
        return 0
    else
        echo "VM $VM_NAME does not exist."
        return 1
    fi
}

# Function to delete the VM
delete_vm() {
    echo "Deleting VM $VM_NAME..."
    if gcloud compute instances delete "$VM_NAME" --quiet; then
        echo "VM $VM_NAME deleted successfully."
    else
        echo "Failed to delete VM $VM_NAME."
        exit 1
    fi
}

# Function to check if the firewall rule exists
check_firewall_rule_existence() {
    if gcloud compute firewall-rules describe "$FIREWALL_RULE_NAME" > /dev/null 2>&1; then
        echo "Firewall rule $FIREWALL_RULE_NAME exists."
        return 0
    else
        echo "Firewall rule $FIREWALL_RULE_NAME does not exist."
        return 1
    fi
}

# Function to delete the firewall rule
delete_firewall_rule() {
    echo "Deleting firewall rule $FIREWALL_RULE_NAME..."
    if gcloud compute firewall-rules delete "$FIREWALL_RULE_NAME" --quiet; then
        echo "Firewall rule $FIREWALL_RULE_NAME deleted successfully."
    else
        echo "Failed to delete firewall rule $FIREWALL_RULE_NAME."
        exit 1
    fi
}

# Main execution
if check_vm_existence; then
    delete_vm
else
    echo "Skipping VM deletion as it does not exist."
fi

if check_firewall_rule_existence; then
    delete_firewall_rule
else
    echo "Skipping firewall rule deletion as it does not exist."
fi

echo "Script completed."
