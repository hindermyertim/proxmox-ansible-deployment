# Ansible Proxmox Infrastructure

Automated deployment of VMs and LXC containers to Proxmox with comprehensive agent configuration and Dashy dashboard integration.

## Features

- 🚀 Deploy Debian VMs and LXC containers to Proxmox via API
- 🔧 Automated agent installation:
  - QEMU guest agent (Proxmox integration)
  - Node Exporter (Prometheus metrics)
  - Newt (Pangolin reverse proxy client)
  - Wazuh (Security monitoring)
  - CheckMK (Infrastructure analytics)
- 📊 Dashy dashboard integration - automatically add new services
- 📝 Easy configuration via YAML files
- 🏠 Designed for homelab/small infrastructure

## Quick Start

### 1. Prerequisites

- Proxmox VE server
- Ansible installed
- Python 3
- (Optional) Dashy dashboard for service tracking

### 2. Setup

```bash
# Clone the repository
git clone <your-repo>
cd ansible-infra

# Install required collections
ansible-galaxy collection install community.general

# Copy example configuration files
cp group_vars/all.yml.example group_vars/all.yml
cp inventory/hosts.yml.example inventory/hosts.yml

# Edit with your Proxmox details
nano group_vars/all.yml
nano inventory/hosts.yml
```

### 3. Set Environment Variables

```bash
# Proxmox connection
export PROXMOX_HOST="your-proxmox-ip"
export PROXMOX_USER="root@pam"
export PROXMOX_PASSWORD="your-password"

# Agent configuration (optional)
export NEWT_SERVER="https://your-pangolin-server.com"
export NEWT_TOKEN="your-token"
export NEWT_ACCEPT_CLIENTS=true  # Optional: Enable Olm client support

export WAZUH_MANAGER_IP="your-wazuh-server"
export CHECKMK_SERVER="your-checkmk-server"
export CHECKMK_SITE="main"

# Dashy dashboard (optional)
export DASHY_HOST="your-dashy-ip"
```

### 4. Deploy

```bash
# Deploy VMs
ansible-playbook playbooks/deploy_vms.yml

# Deploy LXC containers
ansible-playbook playbooks/deploy_lxc.yml

# Configure agents (after VMs/containers are up)
ansible-playbook -i inventory/hosts.yml playbooks/configure_agents.yml

# Add service to Dashy dashboard
export SERVICE_NAME="My Service"
export SERVICE_URL="https://myservice.local"
ansible-playbook playbooks/update_dashy.yml
```

## Project Structure

```
├── playbooks/
│   ├── deploy_vms.yml          # VM deployment
│   ├── deploy_lxc.yml          # LXC deployment
│   ├── configure_agents.yml    # Agent configuration
│   ├── update_dashy.yml        # Update Dashy dashboard
│   └── deploy_with_dashy.yml   # Deploy + update Dashy
├── inventory/
│   └── hosts.yml               # Infrastructure inventory
├── group_vars/
│   └── all.yml                 # VM/container definitions
├── ansible.cfg                 # Ansible settings
└── add-to-dashy.sh            # Interactive Dashy update script
```

## Configuration

### Define VMs (`group_vars/all.yml`)

```yaml
vms:
  - name: web-server
    vmid: 101
    cores: 4
    memory: 4096
    disk_size: 50
    iso: "local:iso/debian-12.5.0-amd64-netinst.iso"
    storage: local-lvm
```

### Define LXC Containers

```yaml
containers:
  - hostname: app-container
    vmid: 201
    template: "local:vztmpl/debian-12-standard_12.2-1_amd64.tar.zst"
    cores: 2
    memory: 2048
    disk_size: 16
    netif:
      net0: "name=eth0,bridge=vmbr0,ip=dhcp"
```

### Configure Agents

Enable/disable agents in `group_vars/all.yml`:

```yaml
install_monitoring: true      # Node Exporter
install_qemu_agent: true      # QEMU guest agent
install_newt: true           # Pangolin Newt agent
install_wazuh: true          # Wazuh agent
install_checkmk: true        # CheckMK agent
```

## Installed Agents

The `configure_agents.yml` playbook can install:

- **QEMU Guest Agent**: Proxmox VM integration
- **Node Exporter**: Prometheus-compatible metrics (port 9100)
- **Newt**: Pangolin reverse proxy/tunneling client
  - Supports `--accept-clients` flag for Olm connections
- **Wazuh Agent**: Security monitoring and threat detection
- **CheckMK Agent**: Infrastructure analytics (port 6556)

Agents are configured via environment variables - only install what you need!

## Dashy Dashboard Integration

Automatically add deployed services to your Dashy dashboard:

### Interactive Mode

```bash
./add-to-dashy.sh
# Follow the prompts
```

### Manual Mode

```bash
export DASHY_HOST="192.168.1.70"
export SERVICE_NAME="Portainer"
export SERVICE_URL="https://portainer.local:9443"
export SERVICE_ICON="hl-portainer"
export SERVICE_SECTION="Container Management"

ansible-playbook playbooks/update_dashy.yml
```

### Deploy + Update Dashboard

```bash
export DEPLOY_TYPE="lxc"
export DASHY_HOST="192.168.1.70"
export SERVICE_NAME="My App"
export SERVICE_URL="https://myapp.local"

ansible-playbook playbooks/deploy_with_dashy.yml
```

Features:
- Automatic config backup before changes
- Creates dashboard sections if they don't exist
- Supports FontAwesome, Homelab icons, emoji, and custom URLs
- Restarts Dashy container automatically

## Security

⚠️ **Important Security Notes:**

- Never commit actual IPs, passwords, or credentials
- Use environment variables for sensitive data
- Consider using Ansible Vault for encryption
- Use Proxmox API tokens instead of root password when possible
- The `.gitignore` is configured to protect your sensitive files

## Customization

### Static IPs

```yaml
netif:
  net0: "name=eth0,bridge=vmbr0,ip=192.168.1.50/24,gw=192.168.1.1"
```

### Selective Agent Installation

Set environment variables only for agents you want:

```bash
# Only install Newt and Node Exporter
export NEWT_SERVER="https://pangolin.example.com"
export NEWT_TOKEN="token"
# Don't set WAZUH_MANAGER_IP or CHECKMK_SERVER - they won't install
```

### Newt with Olm Client Support

Enable Olm client connections:

```bash
export NEWT_ACCEPT_CLIENTS=true
```

## Troubleshooting

### Test Proxmox API Connection

```bash
curl -k -d "username=root@pam&password=YOURPASS" \
  https://YOUR_PROXMOX_IP:8006/api2/json/access/ticket
```

### Test Ansible Connectivity

```bash
ansible -i inventory/hosts.yml all -m ping
```

### List Available ISOs/Templates

```bash
pvesh get /nodes/YOUR_NODE/storage/local/content --content iso
pvesh get /nodes/YOUR_NODE/storage/local/content --content vztmpl
```

## Contributing

Contributions welcome! Please open an issue or PR.

## License

MIT License

## Acknowledgments

- Built with [Ansible](https://www.ansible.com/)
- Uses [community.general](https://docs.ansible.com/ansible/latest/collections/community/general/) collection
- Designed for [Proxmox VE](https://www.proxmox.com/)
- Supports [Pangolin](https://docs.pangolin.net/), Wazuh, CheckMK, and [Dashy](https://dashy.to/) integration
