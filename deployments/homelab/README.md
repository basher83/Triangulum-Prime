# Homelab Deployments

This directory contains all on-premise Proxmox infrastructure managed through Scalr.

## Directory Structure

```
homelab/
├── infrastructure/base/     # Base infrastructure, networking, storage
├── vms/single/             # Single-purpose VMs (DNS, monitoring, etc.)
├── clusters/
│   ├── k8s/               # Kubernetes cluster (MicroK8s)
│   ├── vault/             # HashiCorp Vault cluster
│   └── nomad-consul/      # HashiCorp Nomad + Consul cluster
├── lxc/                   # LXC containers for lightweight services
└── templates/             # VM templates (Ubuntu, Debian, etc.)
```

## Proxmox Clusters

All homelab workspaces have access to three Proxmox clusters:

| Alias | Host | Purpose |
|-------|------|---------|
| `nexus` | 192.168.30.30 | Primary production cluster |
| `matrix` | 192.168.3.5 | Secondary/testing cluster |
| `quantum` | 192.168.10.2 | Development/lab cluster |

## Execution

- **Agent Pool**: bravo-143 (self-hosted)
- **Platform**: OpenTofu 1.10.0+
- **VCS**: GitHub (basher83/triangulum-prime)
- **Branch**: main

## Scalr Workspaces

| Workspace | Directory | Auto-Apply | Purpose |
|-----------|-----------|------------|---------|
| `infra-base` | `infrastructure/base` | No | Networking, storage, firewall |
| `single-vms` | `vms/single` | Yes | Standalone service VMs |
| `k8s-cluster` | `clusters/k8s` | No | Kubernetes cluster |
| `vault-cluster` | `clusters/vault` | No | Secrets management |
| `nomad-consul-cluster` | `clusters/nomad-consul` | No | Workload orchestration |
| `lxc-containers` | `lxc` | Yes | Lightweight containers |
| `vm-templates` | `templates` | No | Template management |

## Common Patterns

### Deploy to Specific Cluster

```hcl
resource "proxmox_virtual_environment_vm" "example" {
  provider = proxmox.nexus  # or matrix, quantum
  # ...
}
```

### Cloud-Init VM

```hcl
resource "proxmox_virtual_environment_vm" "cloudinit_vm" {
  clone {
    vm_id = 9000  # Ubuntu template
    full  = true
  }

  initialization {
    user_account {
      username = "ubuntu"
      keys     = [var.ssh_public_key]
    }

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }
}
```

### HA VM (Multi-Node)

```hcl
resource "proxmox_virtual_environment_vm" "ha_vm" {
  count = 3

  # Distribute across clusters
  provider = count.index == 0 ? proxmox.nexus : (
             count.index == 1 ? proxmox.matrix :
             proxmox.quantum
           )

  name = "ha-vm-${count.index + 1}"
  # ...
}
```

## Variables

Environment variables (all workspaces):

```hcl
variable "default_tags" {
  type = map(string)
  default = {
    managed_by  = "scalr"
    environment = "homelab"
    project     = "triangulum-prime"
  }
}

variable "datacenter" {
  type    = string
  default = "homelab-dc1"
}
```

## Networking

Standard network configuration:

- **Bridge**: vmbr0 (primary network)
- **IP Range**: 192.168.x.x/24 (varies by cluster)
- **VLAN Support**: Yes (vmbr0.X)

## Storage

Common datastores:

- **local**: ISO images and templates
- **local-lvm**: VM disks (default)
- **local-zfs**: ZFS pools (if configured)
- **nfs-backups**: NFS-mounted backup storage

## Backups

Proxmox backup strategy:

1. **Proxmox Backup Server**: Automated backups
2. **DigitalOcean Spaces**: Off-site backups
3. **Snapshots**: Pre-change snapshots

## Monitoring

- **Proxmox built-in**: Basic metrics
- **Prometheus**: Detailed metrics
- **Grafana**: Visualization
- **Alertmanager**: Alerts

## Best Practices

1. **Use templates**: Always clone from templates
2. **Enable QEMU agent**: Better VM management
3. **Resource allocation**: Don't over-provision
4. **HA consideration**: Spread critical VMs across clusters
5. **Backup before changes**: Use Proxmox snapshots
6. **Documentation**: Update README when adding VMs

## Troubleshooting

### Agent Pool Issues

If runs fail with agent pool errors:

```bash
# Check agent status
scalr agent-pools list

# Restart agent on host
systemctl restart scalr-agent
```

### Proxmox API Errors

Check:
- API token expiration
- Permissions (PVEVMAdmin role)
- Network connectivity from agent to Proxmox

### Resource Exhaustion

Monitor:
- CPU usage
- Memory usage
- Storage capacity
- Network bandwidth
