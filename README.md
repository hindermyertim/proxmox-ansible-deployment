> **⚠️ Work in Progress**: This project is actively being developed and improved. Some features may change.

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
- 🎨 Enhanced playbook visualization with Moulti
- 🏠 Designed for homelab/small infrastructure

## Quick Start

### 1. Prerequisites

- Proxmox VE server
- Ansible installed
- Python 3
- pipx (for Moulti installation)
- (Optional) Dashy dashboard for service tracking

### 2. Setup

```bash
# Clone the repository
git clone <your-repo>
cd ansible-infra

# Install Ansible collections
ansible-galaxy collection install -r requirements.yml


# On Debian/Ubuntu, if pip is externally managed, use apt instead:
sudo apt-get install python3-proxmoxer python3-requests
# Install Python dependencies (includes Moulti for enhanced visualization)
pip install -r requirements.txt
# Or with pipx for isolation:
pipx install moulti

# Add pipx bin directory to PATH (if not already)

# Configure environment (Proxmox credentials + agent endpoints)
# This will prompt for all settings and save them to .env
source setup-env.sh

# For future sessions, quickly reload saved settings:
# source .env
export PATH="$HOME/.local/bin:$PATH"
# Make it permanent by adding to ~/.bashrc:
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc

# Copy example configuration files
cp group_vars/all.yml.example group_vars/all.yml
cp inventory/hosts.yml.example inventory/hosts.yml

# Edit with your Proxmox details
nvim group_vars/all.yml
nvim inventory/hosts.yml
```


### 3. Add Containers or VMs

#### For LXC Containers

You have two options for adding new containers:

**Option A: Interactive Helper (Recommended)**

Use the helper script to generate container configurations:

```bash
./add-container.sh
```

This will:
- Prompt you for container specifications (hostname, cores, memory, disk, etc.)
- Generate the YAML configuration
- Optionally deploy immediately

**Option B: Manual Configuration**

Edit `group_vars/all.yml` directly and add your container under the `containers:` section:

```yaml
containers:
  - hostname: nextcloud
    vmid: 202
    template: "local:vztmpl/debian-12-standard_12.2-1_amd64.tar.zst"
    cores: 4
    memory: 4096
    swap: 512
    disk_size: 50
    netif:
      net0: "name=eth0,bridge=vmbr0,ip=dhcp"
    nesting: 1        # Set to 1 for Docker support
    unprivileged: true
    password: "changeme123"
```

#### For VMs

**VMs are now fully automated with cloud-init!**

VMs are deployed using Debian 12 cloud images with automatic SSH key injection and guest agent installation. When you run `./run-playbook.sh` and select "Deploy VMs" (option 1), you'll be prompted to enter:
- VM Name (e.g., webserver-01)
- VM ID (e.g., 108) 
- CPU Cores (default: 2)
- Memory in MB (default: 2048)
- Disk size in GB (default: 32)

The playbook will automatically:
1. ✅ Create the VM with the specified resources
2. ✅ Import and resize the Debian 12 cloud image disk
3. ✅ Inject SSH keys from both this control node AND the Proxmox host
4. ✅ Install qemu-guest-agent via cloud-init for IP detection
5. ✅ Start the VM and wait for it to boot
6. ✅ Detect the VM's IP address automatically
7. ✅ Test SSH connectivity
8. ✅ Add the VM to inventory automatically

**No manual OS installation required!** The VM is ready to use immediately.

> **Note**: The Debian 12 cloud image (`debian-12-genericcloud-amd64.qcow2`) must be downloaded to your Proxmox server. The deployment will guide you through this if needed.

**Post-Deployment:**
- VMs are automatically added to inventory with their detected IP
- Run option 4 (Configure Agents) from the menu to install monitoring agents (Wazuh, CheckMK, Newt)
- SSH access works immediately without manual key setup

### 4. Configure What to Install

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

### 5. Set Environment Variables

```bash
# Proxmox connection
export PROXMOX_HOST="your-proxmox-ip"
export PROXMOX_USER="root@pam"
export PROXMOX_PASSWORD="your-password"

# Agent configuration (optional)
export NEWT_SERVER="https://your-pangolin-server.com"
export NEWT_TOKEN="your-token"

export WAZUH_MANAGER_IP="your-wazuh-server"
export CHECKMK_SERVER="your-checkmk-server"
export CHECKMK_SITE="main"

# Dashy dashboard (optional)
export DASHY_HOST="your-dashy-ip"
```

### 6. Deploy

#### Quick Start - Interactive Menu

```bash
# Use the interactive menu to choose which playbook to run
./run-playbook.sh

# Or run in dry-run mode to see what would happen without making changes
./run-playbook.sh --check
```


This will launch an interactive Moulti interface where you can:
- Choose from:
  - Deploy VMs (standalone or with agent configuration)
  - Deploy LXC Containers (standalone or with agent configuration)
  - Configure Agents on existing systems
  - Update Dashy Dashboard
- See real-time progress with enhanced visualization

#### Manual Execution

```bash
# Deploy VMs (with Moulti for better visualization)
moulti run ansible-playbook playbooks/deploy_vms.yml

# Deploy LXC containers
moulti run ansible-playbook playbooks/deploy_lxc.yml

# Configure agents and install software (after VMs/containers are up)
moulti run ansible-playbook -i inventory/hosts.yml playbooks/configure_agents.yml

# Add service to Dashy dashboard
export SERVICE_NAME="My Service"
export SERVICE_URL="https://myservice.local"
moulti run ansible-playbook playbooks/update_dashy.yml
```

**Note:** You can still use standard `ansible-playbook` commands if you prefer. Moulti provides an enhanced TUI that shows each task as a separate step with real-time output, making it easier to track progress and debug issues.

## Moulti - Enhanced Playbook Visualization

Moulti provides a beautiful terminal UI that displays Ansible playbook execution with:
- ✨ Step-by-step task visualization
- 📊 Real-time output for each task
- 🎯 Easy navigation through playbook execution
- 🔍 Better debugging with organized output
## Agent Configuration

The playbook can automatically configure monitoring and management agents on deployed systems:

### Supported Agents

1. **Wazuh** - Security monitoring and threat detection
2. **Pangolin/Newt** - Reverse proxy tunneling for remote access
3. **CheckMK** - Infrastructure monitoring

### Environment Variables

Agent endpoints are configured when you run `setup-env.sh`. You will be prompted for:

- **Proxmox Host** - IP or hostname of your Proxmox server
- **Proxmox User** - Authentication user (default: root@pam)
- **Proxmox Password** - Your Proxmox password
- **Wazuh Manager IP** (optional) - For security monitoring
- **Pangolin/Newt Endpoint** (optional) - For reverse proxy tunneling
- **CheckMK Server** (optional) - For infrastructure monitoring
- **CheckMK Site** (optional) - CheckMK site name (default: main)

All settings are saved to `.env` file for future use.

### Interactive Prompts

When deploying with agent configuration, you will be prompted for:

- **Wazuh Agent Group** (optional) - For organizing agents
- **Newt ID & Secret** (required) - Credentials from Pangolin site creation

All other settings are read from environment variables. If an environment variable is not set, that agent will be skipped.



### Usage

Simply prefix your `ansible-playbook` commands with `moulti run`:

```bash
# Standard command
ansible-playbook playbooks/deploy_vms.yml

# With Moulti
moulti run ansible-playbook playbooks/deploy_vms.yml
```

### Installation Options

```bash
# Recommended: Install with pipx
pipx install moulti

# Or install system-wide (not recommended)
pip install moulti

# Or on Debian/Ubuntu
apt install pipx
pipx install moulti
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

moulti run ansible-playbook playbooks/update_dashy.yml
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
moulti run ansible-playbook playbooks/deploy_lxc.yml
moulti run ansible-playbook -i inventory/hosts.yml playbooks/configure_agents.yml
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


```bash
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

### Moulti Not Found

Ensure pipx bin directory is in your PATH:
```bash
export PATH="$HOME/.local/bin:$PATH"
```

## Contributing

Contributions welcome! Please open an issue or PR.

## License

MIT License

## Acknowledgments

- Built with [Ansible](https://www.ansible.com/)
- Uses [community.general](https://docs.ansible.com/ansible/latest/collections/community/general/) collection
- Designed for [Proxmox VE](https://www.proxmox.com/)
- Enhanced visualization with [Moulti](https://github.com/xavierog/moulti)
- Supports [Pangolin](https://pangolin.net/), [Wazuh](https://wazuh.com/), [CheckMK](https://checkmk.com/), and [Dashy](https://dashy.to/) integration
- Docker from official [Docker repository](https://docs.docker.com/)
