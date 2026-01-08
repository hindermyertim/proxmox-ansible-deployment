#!/bin/bash
# Interactive playbook runner with Moulti visualization

export PATH="$HOME/.local/bin:$PATH"

# Check if moulti is installed
if ! command -v moulti &> /dev/null; then
    echo "Error: moulti is not installed. Please run: pip install -r requirements.txt"
    exit 1
fi

# Function to prompt for VM configuration
prompt_vm_config() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "VM Configuration"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    read -p "VM Name (e.g., debian-vm-02): " vm_name
    read -p "VM ID (e.g., 102): " vm_id
    read -p "CPU Cores (default: 2): " vm_cores
    vm_cores=${vm_cores:-2}
    read -p "Memory in MB (default: 2048): " vm_memory
    vm_memory=${vm_memory:-2048}
    read -p "Disk size in GB (default: 32): " vm_disk
    vm_disk=${vm_disk:-32}
    
    VM_VARS="-e vm_name=$vm_name -e vm_id=$vm_id -e vm_cores=$vm_cores -e vm_memory=$vm_memory -e vm_disk=$vm_disk"
    
    echo ""
    echo "✓ VM Configuration:"
    echo "  Name: $vm_name"
    echo "  ID: $vm_id"
    echo "  Cores: $vm_cores"
    echo "  Memory: ${vm_memory}MB"
    echo "  Disk: ${vm_disk}GB"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

prompt_agent_configs() {
# Function to prompt for Wazuh configuration
prompt_wazuh_config() {
    # Use environment variable or skip
    WAZUH_MANAGER="${WAZUH_MANAGER_IP:-}"
    
    if [[ -z "$WAZUH_MANAGER" ]]; then
        echo ""
        echo "⊘ Skipping Wazuh (set WAZUH_MANAGER_IP env var to enable)"
        WAZUH_VARS=""
        return
    fi
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Wazuh Agent Configuration"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Manager: $WAZUH_MANAGER"
    echo ""
    read -p "Agent Group (press Enter for Default): " wazuh_group
    
    WAZUH_VARS="-e wazuh_manager_ip='$WAZUH_MANAGER'"
    if [[ -n "$wazuh_group" ]]; then
        WAZUH_VARS="$WAZUH_VARS -e wazuh_agent_group='$wazuh_group'"
    fi
    
    echo "✓ Wazuh configuration will be applied"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# Function to prompt for Newt/Pangolin configuration
prompt_newt_config() {
    # Use environment variable or skip
    NEWT_ENDPOINT="${NEWT_ENDPOINT:-}"
    
    if [[ -z "$NEWT_ENDPOINT" ]]; then
        echo ""
        echo "⊘ Skipping Newt (set NEWT_ENDPOINT env var to enable)"
        NEWT_VARS=""
        return
    fi
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Pangolin/Newt Configuration"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Endpoint: $NEWT_ENDPOINT"
    echo ""
    read -p "Newt ID: " newt_id
    read -sp "Newt Secret: " newt_secret
    echo ""
    
    if [[ -z "$newt_id" || -z "$newt_secret" ]]; then
        echo "⊘ Skipping Newt (ID or Secret not provided)"
        NEWT_VARS=""
    else
        NEWT_VARS="-e newt_endpoint='$NEWT_ENDPOINT' -e newt_id='$newt_id' -e newt_secret='$newt_secret'"
        echo "✓ Newt configuration will be applied"
    
    fi
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# Function to prompt for CheckMK configuration
prompt_checkmk_config() {
    # Use environment variables or skip
    CHECKMK_SERVER="${CHECKMK_SERVER:-}"
    CHECKMK_SITE="${CHECKMK_SITE:-main}"
    
    if [[ -z "$CHECKMK_SERVER" ]]; then
        echo ""
        echo "⊘ Skipping CheckMK (set CHECKMK_SERVER env var to enable)"
        CHECKMK_VARS=""
        return
    fi
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "CheckMK Agent Configuration"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Server: $CHECKMK_SERVER"
    echo "Site: $CHECKMK_SITE"
    echo ""
    
    CHECKMK_VARS="-e checkmk_server='$CHECKMK_SERVER' -e checkmk_site='$CHECKMK_SITE'"
    echo "✓ CheckMK configuration will be applied"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# Combined function to prompt for all agent configs
prompt_agent_configs() {
    prompt_wazuh_config
    prompt_newt_config
    prompt_checkmk_config
    
    # Combine all extra vars
    EXTRA_VARS="$WAZUH_VARS $NEWT_VARS $CHECKMK_VARS"
}
    prompt_wazuh_config
    prompt_newt_config
    prompt_checkmk_config
    
    # Combine all extra vars
    EXTRA_VARS="$WAZUH_VARS $NEWT_VARS $CHECKMK_VARS"
}

# Parse command line arguments
DRY_RUN=""
if [[ "$1" == "--check" ]] || [[ "$1" == "--dry-run" ]]; then
    DRY_RUN="--check"
    echo "🔍 DRY RUN MODE - No changes will be made"
    echo ""
fi

echo "╔════════════════════════════════════════════════════════════╗"
echo "║        Ansible Proxmox Infrastructure Manager              ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "Select a playbook to run:"
echo ""

PS3=$'\nEnter your choice (1-7): '
options=(
    "Deploy VMs"
    "Deploy VMs + Configure Agents"
    "Deploy LXC Containers"
    "Deploy LXC Containers + Configure Agents"
    "Configure Agents"
    "Update Dashy Dashboard"
    "Exit"
)

select opt in "${options[@]}"
do
    case $REPLY in
        1)
            echo ""
            prompt_vm_config
            echo ""
            echo "→ Running: Deploy VMs ${DRY_RUN:+(dry run)}"
            moulti run ansible-playbook playbooks/deploy_vms.yml $DRY_RUN $VM_VARS
            break
            ;;
        2)
            echo ""
            prompt_vm_config
            echo ""
            prompt_agent_configs
            echo ""
            echo "→ Running: Deploy VMs + Configure Agents ${DRY_RUN:+(dry run)}"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            
            moulti run bash -c "
export PATH=\"\$HOME/.local/bin:\$PATH\"

moulti step add step1 --title='Step 1/2: Deploy VMs ${DRY_RUN:+(dry run)}' --classes='standard'
ansible-playbook playbooks/deploy_vms.yml $DRY_RUN $VM_VARS 2>&1 | moulti pass step1

moulti divider add div1 --title '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'

moulti step add step2 --title='Step 2/2: Configure Agents ${DRY_RUN:+(dry run)}' --classes='standard'
ansible-playbook -i inventory/hosts.yml playbooks/configure_agents.yml $DRY_RUN $EXTRA_VARS 2>&1 | moulti pass step2

moulti divider add div2 --title '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'
moulti step add complete --title='✓ Complete' --text='="VM deployment finished! ${DRY_RUN:+(dry run - no changes made)}' --classes='="success'
"
            break
            ;;
        3)
            echo ""
            echo "→ Running: Deploy LXC Containers ${DRY_RUN:+(dry run)}"
            moulti run ansible-playbook playbooks/deploy_lxc.yml $DRY_RUN
            break
            ;;
        4)
            echo ""
            prompt_agent_configs
            echo ""
            echo "→ Running: Deploy LXC Containers + Configure Agents ${DRY_RUN:+(dry run)}"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            
            moulti run bash -c "
export PATH=\"\$HOME/.local/bin:\$PATH\"

moulti step add step1 --title='Step 1/2: Deploy LXC Containers ${DRY_RUN:+(dry run)}' --classes='standard'
ansible-playbook playbooks/deploy_lxc.yml $DRY_RUN 2>&1 | moulti pass step1

moulti divider add div1 --title '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'

moulti step add step2 --title='Step 2/2: Configure Agents ${DRY_RUN:+(dry run)}' --classes='standard'
ansible-playbook -i inventory/hosts.yml playbooks/configure_agents.yml $DRY_RUN $EXTRA_VARS 2>&1 | moulti pass step2

moulti divider add div2 --title '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'
moulti step add complete --title='✓ Complete' --text='LXC deployment finished! ${DRY_RUN:+(dry run - no changes made)}' --classes='success'
"
            break
            ;;
        5)
            echo ""
            prompt_agent_configs
            echo ""
            echo "→ Running: Configure Agents ${DRY_RUN:+(dry run)}"
            moulti run ansible-playbook -i inventory/hosts.yml playbooks/configure_agents.yml $DRY_RUN $EXTRA_VARS
            break
            ;;
        6)
            echo ""
            echo "→ Running: Update Dashy Dashboard ${DRY_RUN:+(dry run)}"
            moulti run ansible-playbook playbooks/update_dashy.yml $DRY_RUN
            break
            ;;
        7)
            echo ""
            echo "Goodbye!"
            exit 0
            ;;
        *)
            echo "Invalid option. Please select 1-7."
            ;;
    esac
done
