#!/bin/bash
# Quick script to add a service to Dashy dashboard

set -e

echo "=== Add Service to Dashy Dashboard ==="
echo ""

# Prompt for required info
read -p "Service Name: " SERVICE_NAME
read -p "Service URL: " SERVICE_URL
read -p "Description (optional): " SERVICE_DESCRIPTION
read -p "Icon (optional, e.g., fas fa-server): " SERVICE_ICON
read -p "Section (default: Homelab Services): " SERVICE_SECTION
SERVICE_SECTION=${SERVICE_SECTION:-Homelab Services}

# Set Dashy details
read -p "Dashy Host IP (default: 192.168.1.70): " DASHY_HOST
DASHY_HOST=${DASHY_HOST:-192.168.1.70}

# Export variables
export DASHY_HOST
export SERVICE_NAME
export SERVICE_URL
export SERVICE_DESCRIPTION
export SERVICE_ICON
export SERVICE_SECTION

# Run playbook
echo ""
echo "Adding $SERVICE_NAME to Dashy..."
ansible-playbook playbooks/update_dashy.yml

echo ""
echo "✓ Done! Check your Dashy dashboard at http://$DASHY_HOST"
