#!/bin/bash
# Interactive playbook runner with Moulti visualization

export PATH="$HOME/.local/bin:$PATH"

# Check if moulti is installed
if ! command -v moulti &> /dev/null; then
    echo "Error: moulti is not installed. Please run: pip install -r requirements.txt"
    exit 1
fi

echo "╔════════════════════════════════════════════════════════════╗"
echo "║        Ansible Proxmox Infrastructure Manager              ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "Select a playbook to run:"
echo ""

PS3=$'\nEnter your choice (1-6): '
options=(
    "Deploy VMs"
    "Deploy LXC Containers"
    "Configure Agents"
    "Update Dashy Dashboard"
    "Full Deploy (VMs + LXC + Configure)"
    "Exit"
)

select opt in "${options[@]}"
do
    case $REPLY in
        1)
            echo ""
            echo "→ Running: Deploy VMs"
            moulti run ansible-playbook playbooks/deploy_vms.yml
            break
            ;;
        2)
            echo ""
            echo "→ Running: Deploy LXC Containers"
            moulti run ansible-playbook playbooks/deploy_lxc.yml
            break
            ;;
        3)
            echo ""
            echo "→ Running: Configure Agents"
            moulti run ansible-playbook -i inventory/hosts.yml playbooks/configure_agents.yml
            break
            ;;
        4)
            echo ""
            echo "→ Running: Update Dashy Dashboard"
            moulti run ansible-playbook playbooks/update_dashy.yml
            break
            ;;
        5)
            echo ""
            echo "→ Running: Full Deploy (VMs + LXC + Configure)"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            
            moulti run bash << 'SCRIPT'
export PATH="$HOME/.local/bin:$PATH"

moulti step add step1 --title="Step 1/3: Deploy VMs" --classes="standard"
ansible-playbook playbooks/deploy_vms.yml 2>&1 | moulti pass step1

moulti divider add div1 --text="━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

moulti step add step2 --title="Step 2/3: Deploy LXC Containers" --classes="standard"
ansible-playbook playbooks/deploy_lxc.yml 2>&1 | moulti pass step2

moulti divider add div2 --text="━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

moulti step add step3 --title="Step 3/3: Configure Agents" --classes="standard"
ansible-playbook -i inventory/hosts.yml playbooks/configure_agents.yml 2>&1 | moulti pass step3

moulti divider add div3 --text="━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
moulti step add complete --title="✓ Complete" --text="Full deployment finished!" --classes="success"
SCRIPT
            break
            ;;
        6)
            echo ""
            echo "Goodbye!"
            exit 0
            ;;
        *)
            echo "Invalid option. Please select 1-6."
            ;;
    esac
done
