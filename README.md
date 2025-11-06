# Ansible Proxmox Infrastructure

Automated deployment of VMs and LXC containers to Proxmox with agent configuration.

## Features

- 🚀 Deploy Debian VMs and LXC containers to Proxmox via API
- 🔧 Automated agent installation (QEMU guest agent, monitoring)
- 📝 Easy configuration via YAML files
- 🏠 Designed for homelab/small infrastructure

## Quick Start

### 1. Prerequisites

- Proxmox VE server
- Ansible installed
- Python 3

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
export PROXMOX_HOST="your-proxmox-ip"
export PROXMOX_USER="root@pam"
export PROXMOX_PASSWORD="your-password"
```

### 4. Deploy

```bash
# Deploy VMs
ansible-playbook playbooks/deploy_vms.yml

# Deploy LXC containers
ansible-playbook playbooks/deploy_lxc.yml

# Configure agents (after VMs/containers are up)
ansible-playbook -i inventory/hosts.yml playbooks/configure_agents.yml
```

## Project Structure

```
├── playbooks/
│   ├── deploy_vms.yml          # VM deployment
│   ├── deploy_lxc.yml          # LXC deployment
│   └── configure_agents.yml    # Agent configuration
├── inventory/
│   └── hosts.yml               # Infrastructure inventory
├── group_vars/
│   └── all.yml                 # VM/container definitions
└── ansible.cfg                 # Ansible settings
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

## Installed Agents

The `configure_agents.yml` playbook installs:

- **QEMU Guest Agent**: For Proxmox VM integration
- **Node Exporter**: Prometheus-compatible metrics (port 9100)

Add more agents by editing `playbooks/configure_agents.yml`.

## Security

⚠️ **Important Security Notes:**

- Never commit actual IPs, passwords, or credentials
- Use environment variables for sensitive data
- Consider using Ansible Vault for encryption
- Use Proxmox API tokens instead of root password when possible

## Customization

### Static IPs

```yaml
netif:
  net0: "name=eth0,bridge=vmbr0,ip=192.168.1.50/24,gw=192.168.1.1"
```

### Add More Agents

Edit `playbooks/configure_agents.yml` to add:
- Docker
- Telegraf
- Custom monitoring
- Backup agents

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

MIT License - see LICENSE file

## Acknowledgments

- Built with [Ansible](https://www.ansible.com/)
- Uses [community.general](https://docs.ansible.com/ansible/latest/collections/community/general/) collection
- Designed for [Proxmox VE](https://www.proxmox.com/)
