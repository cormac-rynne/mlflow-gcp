#!/bin/bash

# Get the directory of the current script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Get the parent directory of the script
PARENT_DIR="$(dirname "$DIR")"

# Automatically export all variables from the .env file in the parent directory
set -a
source "$PARENT_DIR/.env"
set +a

get_my_ip_address() {
    # Find your public IP address
    echo "Finding your public IP address..."
    MY_IP=$(curl -s http://ipinfo.io/ip)
    echo "Your public IP address is $MY_IP"
}

# Function to check if the firewall rule already exists
check_firewall_rule_existence() {
    if gcloud compute firewall-rules describe "$FIREWALL_RULE_NAME" > /dev/null 2>&1; then
        echo "Firewall rule $FIREWALL_RULE_NAME already exists"
        return 0
    else
        return 1
    fi
}

# Function to create a firewall rule
create_firewall_rule() {
    echo "Creating firewall rule..."
    if ! gcloud compute firewall-rules create "$FIREWALL_RULE_NAME" \
        --direction=INGRESS \
        --priority=1000 \
        --network="$NETWORK" \
        --action=ALLOW \
        --rules=tcp:80,tcp:443,tcp:8000,tcp:5000,tcp:5432 \
        --source-ranges="$MY_IP/32" \
        --target-tags="$TARGET_TAG"; then
        echo "Failed to create firewall rule. Exiting..."
        exit 1
    fi
}

# Function to add tags to the VM
add_tags_to_vm() {
    echo "Adding tags to the VM..."
    if ! gcloud compute instances add-tags "$VM_NAME" --tags "$TARGET_TAG"; then
        echo "Failed to add tags to VM. Exiting..."
        exit 1
    fi
}

# Main script execution
get_my_ip_address
if check_firewall_rule_existence; then
    echo "No need to create the firewall rule as it already exists."
else
    create_firewall_rule
fi

add_tags_to_vm
echo "Firewall rule applied to VM successfully."