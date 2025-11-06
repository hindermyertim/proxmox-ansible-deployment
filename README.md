# Ansible Proxmox Infrastructure

Automated deployment of VMs and LXC containers to Proxmox with comprehensive agent configuration and Dashy dashboard integration.

## Features

- 🚀 Deploy Debian VMs and LXC containers to Proxmox via API
- 🔧 Automated software installation:
  - Base tools (Neovim, git, curl, wget, htop)
  - Docker & Docker Compose (optional)
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
nvim group_vars/all.yml
nvim inventory/hosts.yml
```

### 3. Configure What to Install

Edit `group_vars/all.yml`:

```yaml
# Software installation
install_base_tools: true     # Neovim, git, curl, etc. (always recommended)
install_docker: false        # Docker CE + Docker Compose (set true if needed)

# Agents
install_monitoring: true     # Node Exporter
install_qemu_agent: true     # QEMU guest agent
install_newt: true          # Pangolin Newt
install_wazuh: true         # Wazuh
install_checkmk: true       # CheckMK
```

### 4. Set Environment Variables

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

### 5. Deploy

```bash
# Deploy VMs
ansible-playbook playbooks/deploy_vms.yml

# Deploy LXC containers
ansible-playbook playbooks/deploy_lxc.yml

# Configure agents and install software (after VMs/containers are up)
ansible-playbook -i inventory/hosts.yml playbooks/configure_agents.yml

# Add service to Dashy dashboard
export SERVICE_NAME="My Service"
export SERVICE_URL="https://myservice.local"
ansible-playbook playbooks/update_dashy.yml
```

## Installed Software & Agents

### Base Tools (Always Installed)
- **Neovim** - Text editor (set as default)
- **Git, curl, wget** - Essential utilities
- **Htop** - Process monitor
- **Net-tools** - Network utilities

### Docker (Optional)
Set `install_docker: true` in `group_vars/all.yml` to install:
- **Docker CE** - Latest stable Docker engine
- **Docker Compose** - v2 plugin (`docker compose`)
- **Docker Buildx** - Build multi-platform images

**Note:** LXC containers need `nesting: 1` to run Docker!

### Monitoring & Security Agents
- **QEMU Guest Agent** - Proxmox VM integration
- **Node Exporter** - Prometheus metrics (port 9100)
- **Newt** - Pangolin reverse proxy/tunneling client
  - Supports `--accept-clients` flag for Olm connections
- **Wazuh Agent** - Security monitoring
- **CheckMK Agent** - Infrastructure analytics (port 6556)

Agents are configured via environment variables - only install what you need!

## Dashy Dashboard Integration

Automatically add deployed services to your Dashy dashboard:

### Interactive Mode

```bash
./add-to-dashy.sh
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

## Docker Deployment Example

Deploy a container with Docker pre-installed:

```yaml
# group_vars/all.yml
containers:
  - hostname: docker-host
    vmid: 203
    cores: 4
    memory: 4096
    disk_size: 50
    nesting: 1  # REQUIRED for Docker!
    
install_docker: true  # Install Docker
```

Then deploy and configure:

```bash
ansible-playbook playbooks/deploy_lxc.yml
ansible-playbook -i inventory/hosts.yml playbooks/configure_agents.yml
```

SSH in and Docker is ready to use!

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

### Disable Specific Features

```yaml
install_base_tools: false    # Skip neovim, git, etc.
install_docker: false        # No Docker (default)
install_newt: false         # Skip Pangolin
install_wazuh: false        # Skip Wazuh
install_checkmk: false      # Skip CheckMK
```

### Newt with Olm Client Support

```bash
export NEWT_ACCEPT_CLIENTS=true
```

## Troubleshooting

### Test Proxmox API

```bash
curl -k -d "username=root@pam&password=YOURPASS" \
  https://YOUR_PROXMOX_IP:8006/api2/json/access/ticket
```

### Test Ansible Connectivity

```bash
ansible -i inventory/hosts.yml all -m ping
```

### Docker Not Working in LXC

Make sure container has `nesting: 1` enabled in definition!

## Contributing

Contributions welcome! Please open an issue or PR.

## License

MIT License

## Acknowledgments

- Built with [Ansible](https://www.ansible.com/)
- Uses [community.general](https://docs.ansible.com/ansible/latest/collections/community/general/) collection
- Designed for [Proxmox VE](https://www.proxmox.com/)
- Supports [Pangolin](https://docs.pangolin.net/), Wazuh, CheckMK, and [Dashy](https://dashy.to/) integration
- Docker from official [Docker repository](https://docs.docker.com/)
