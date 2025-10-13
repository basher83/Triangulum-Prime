# Homelab VM Templates

**Scalr Workspaces:**
- `homelab/vm-templates-matrix` - Matrix cluster (192.168.3.5)
- `homelab/vm-templates-nexus` - Nexus cluster (192.168.30.30)
- `homelab/vm-templates-quantum` - Quantum cluster (192.168.10.2)

**Execution Mode:** Remote (Scalr agent: bravo-143)
**Auto Apply:** No

## Purpose

This directory contains a root orchestrator that deploys VM templates to Proxmox clusters. Each Scalr workspace deploys the **same templates** to different clusters using cluster-specific provider configurations.

### Templates Managed

- **Ubuntu 22.04 LTS** - Template ID 9000
- **Ubuntu 24.04 LTS** - Template ID 9001
- Cloud-init enabled templates
- Shared cloud-init user-data configuration

### Directory Structure

```
templates/
├── main.tf                    # Root orchestrator
├── variables.tf               # All variables
├── outputs.tf                 # Template outputs
├── versions.tf                # Provider requirements
├── shared/
│   └── user-data.yaml        # Shared cloud-init config
├── ubuntu-22-cloudinit/      # Ubuntu 22.04 template module
└── ubuntu-24-cloudinit/      # Ubuntu 24.04 template module
```

## Template Strategy

### Cloud Images

Use official cloud images for best practice:

```
Ubuntu: https://cloud-images.ubuntu.com/
Debian: https://cloud.debian.org/images/cloud/
Rocky: https://rockylinux.org/cloud-images
```

### Template Best Practices

1. **Enable cloud-init** for automated configuration
2. **Install QEMU guest agent** for better integration
3. **Update packages** before converting to template
4. **Remove SSH host keys** (regenerated on clone)
5. **Set appropriate disk size** (easily expanded later)
6. **Use virtio drivers** for better performance

## How Workspaces Work

### Multi-Cluster Deployment

Each workspace uses:
1. **Same code** (`working_directory: deployments/homelab/templates`)
2. **Different provider config** (via `provider_configs` in workspace YAML)
3. **Cluster-specific variables** (via workspace variables)

### Workspace Variables

Each workspace sets cluster-specific variables:

**Matrix Workspace:**
- `proxmox_endpoint` = "https://192.168.3.5:8006"
- `proxmox_node` = "pve-matrix-01"

**Nexus Workspace:**
- `proxmox_endpoint` = "https://192.168.30.30:8006"
- `proxmox_node` = "pve-nexus-01"

**Quantum Workspace:**
- `proxmox_endpoint` = "https://192.168.10.2:8006"
- `proxmox_node` = "pve-quantum-01"

### VCS Triggers

All three workspaces trigger on changes to:
```
deployments/homelab/templates/**/*
!deployments/homelab/templates/README.md
```

This ensures template updates automatically deploy to all clusters.

## Template IDs

Standard template ID ranges:

- `9000-9099`: Ubuntu templates
- `9100-9199`: Debian templates
- `9200-9299`: Rocky/Alma templates
- `9300-9399`: Custom templates

## Usage in Other Workspaces

```hcl
resource "proxmox_virtual_environment_vm" "example" {
  clone {
    vm_id = 9000  # Ubuntu 22.04 template
    full  = true
  }

  # Override template settings
  cpu {
    cores = 4
  }

  memory {
    dedicated = 8192
  }
}
```

## Cloud-Init Configuration

Templates should support cloud-init for:

- SSH key injection
- User creation
- Package installation
- Network configuration
- Custom scripts

## Maintenance

Regularly update templates:

1. Clone template to VM
2. Update packages
3. Test functionality
4. Convert back to template
5. Update version tags
