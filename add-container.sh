#!/bin/bash
# Quick container configuration helper

echo "╔════════════════════════════════════════════════════════════╗"
echo "║           Add New LXC Container Configuration              ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Prompt for container details
read -p "Container hostname (e.g., nextcloud): " HOSTNAME
read -p "VM ID (e.g., 202): " VMID
read -p "CPU cores (default: 2): " CORES
CORES=${CORES:-2}
read -p "Memory in MB (default: 2048): " MEMORY
MEMORY=${MEMORY:-2048}
read -p "Disk size in GB (default: 20): " DISK
DISK=${DISK:-20}
read -p "Enable Docker support? (y/n, default: n): " DOCKER
read -p "Swap in MB (default: 512): " SWAP
SWAP=${SWAP:-512}

echo ""
echo "Container Configuration:"
echo "  Hostname: $HOSTNAME"
echo "  VMID: $VMID"
echo "  Cores: $CORES"
echo "  Memory: ${MEMORY}MB"
echo "  Disk: ${DISK}GB"
echo "  Swap: ${SWAP}MB"
echo "  Docker: ${DOCKER}"
echo ""

# Generate YAML snippet
cat << YAML

# Add this to your group_vars/all.yml under the 'containers:' section:

  - hostname: ${HOSTNAME}
    vmid: ${VMID}
    template: "local:vztmpl/debian-12-standard_12.2-1_amd64.tar.zst"
    cores: ${CORES}
    memory: ${MEMORY}
    swap: ${SWAP}
    disk_size: ${DISK}
    netif:
      net0: "name=eth0,bridge=vmbr0,ip=dhcp"
    nesting: $( [[ "$DOCKER" =~ ^[Yy]$ ]] && echo "1" || echo "0" )
    unprivileged: true
    password: "changeme123"

YAML

echo ""
read -p "Copy this to group_vars/all.yml, then press Enter to continue..."
read -p "Do you want to run the deployment now? (y/n): " RUN

if [[ "$RUN" =~ ^[Yy]$ ]]; then
    echo ""
    echo "Deploying LXC container..."
    ./run-playbook.sh
else
    echo "Configuration saved. Run './run-playbook.sh' when ready to deploy."
fi
