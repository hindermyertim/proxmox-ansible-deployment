#!/bin/bash
# Quick VM configuration helper

echo "╔════════════════════════════════════════════════════════════╗"
echo "║              Add New VM Configuration                      ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Prompt for VM details
read -p "VM name (e.g., debian-vm-02): " VMNAME
read -p "VM ID (e.g., 102): " VMID
read -p "CPU cores (default: 2): " CORES
CORES=${CORES:-2}
read -p "Memory in MB (default: 2048): " MEMORY
MEMORY=${MEMORY:-2048}
read -p "Disk size in GB (default: 32): " DISK
DISK=${DISK:-32}

echo ""
echo "VM Configuration:"
echo "  Name: $VMNAME"
echo "  VMID: $VMID"
echo "  Cores: $CORES"
echo "  Memory: ${MEMORY}MB"
echo "  Disk: ${DISK}GB"
echo ""

# Generate YAML snippet
cat << YAML

# Add this to your group_vars/all.yml under the 'vms:' section:

  - name: ${VMNAME}
    vmid: ${VMID}
    cores: ${CORES}
    memory: ${MEMORY}
    disk_size: ${DISK}
    iso: "local:iso/debian-12.5.0-amd64-netinst.iso"
    ostype: l26
    storage: local-lvm

YAML

echo ""
read -p "Copy this to group_vars/all.yml, then press Enter to continue..."
read -p "Do you want to run the deployment now? (y/n): " RUN

if [[ "$RUN" =~ ^[Yy]$ ]]; then
    echo ""
    echo "Deploying VM..."
    ./run-playbook.sh
else
    echo "Configuration saved. Run './run-playbook.sh' when ready to deploy."
fi
