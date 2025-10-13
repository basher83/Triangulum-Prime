# Template Creation from URL Example

This example demonstrates creating a Proxmox VM template by automatically downloading a cloud image from a URL. This replaces manual image downloads and shell scripts with Terraform-managed infrastructure.

## What This Does

1. **Downloads** a cloud image from the specified URL (e.g., Ubuntu Cloud Image)
2. **Creates** a Proxmox VM template from the downloaded image
3. **Outputs** the template ID for use in VM cloning operations

## Use Cases

- **Replace shell scripts**: Transition from manual download timers to Terraform-managed templates
- **Reproducible templates**: Ensure consistent template creation across environments
- **Version control**: Track template configuration in Git
- **Automation**: Integrate with CI/CD for scheduled template updates

## Prerequisites

1. Proxmox VE cluster with API access
2. **SSH access to Proxmox host** (required for image import operations)
   - SSH user with appropriate permissions (e.g., `terraform` user)
   - SSH key authentication configured (password auth not recommended)
   - SSH agent forwarding enabled for your local SSH agent
3. Datastore with sufficient space for cloud images (~200MB per image)
4. `local` datastore enabled for snippets (cloud-init)
5. Network connectivity to download cloud images

## Quick Start

### 1. Copy Example Configuration

```bash
cd terraform/deployments/examples/template-from-url
cp terraform.tfvars.example terraform.tfvars
```

### 2. Configure Variables

Edit `terraform.tfvars`:

```hcl
proxmox_endpoint = "https://proxmox.example.com:8006"
proxmox_node     = "lloyd"
template_name    = "ubuntu-22-04-template"
template_id      = 2006
cloud_image_url  = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
```

### 3. Configure Provider with SSH Support

Template creation requires SSH access to import cloud images. Update your provider configuration:

```hcl
# provider.tf
provider "proxmox" {
  endpoint = var.proxmox_endpoint
  insecure = var.proxmox_insecure

  # API authentication
  # Set via environment: PROXMOX_VE_USERNAME, PROXMOX_VE_PASSWORD
  # Or use API token: PROXMOX_VE_API_TOKEN

  # SSH required for image import operations
  ssh {
    agent    = true                # Use local SSH agent
    username = var.ssh_username    # SSH user on Proxmox host
  }
}

variable "ssh_username" {
  type        = string
  description = "SSH username for Proxmox host"
  default     = "terraform"        # Or "root"
}
```

### 4. Set Up SSH Access

```bash
# Ensure SSH agent is running and has your key loaded
eval $(ssh-agent)
ssh-add ~/.ssh/id_rsa  # Or your specific key

# Test SSH access to Proxmox
ssh terraform@proxmox-host "echo 'SSH working'"

# Set Proxmox API credentials
export PROXMOX_VE_USERNAME="root@pam"
export PROXMOX_VE_PASSWORD="your-password"
# OR
export PROXMOX_VE_API_TOKEN="user@realm!token=secret"
```

### 5. Deploy Template

```bash
tofu init
tofu plan
tofu apply
```

### 6. Verify Template Creation

```bash
# Via Terraform output
tofu output template_id

# Via Proxmox CLI
ssh terraform@proxmox "qm list | grep 2006"
```

## Cloud Image Sources

### Ubuntu Cloud Images

```hcl
# Ubuntu 22.04 LTS (Jammy)
cloud_image_url = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"

# Ubuntu 24.04 LTS (Noble)
cloud_image_url = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
```

**Checksums**: https://cloud-images.ubuntu.com/jammy/current/SHA256SUMS

### Debian Cloud Images

```hcl
# Debian 12 (Bookworm)
cloud_image_url = "https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-generic-amd64.qcow2"
```

### Rocky Linux Cloud Images

```hcl
# Rocky Linux 9
cloud_image_url = "https://download.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-GenericCloud-Base.latest.x86_64.qcow2"
```

## Template Configuration

### Minimal Template (Default)

The example creates a minimal template optimized for cloning:

- **BIOS**: UEFI (ovmf)
- **Machine**: q35
- **CPU**: 2 cores (host passthrough)
- **Memory**: 2048 MB
- **Disk**: 32 GB (resizable during clone)
- **Network**: Single NIC, DHCP

### Customizing the Template

Edit `main.tf` to adjust:

```hcl
module "ubuntu_template" {
  # ...

  vm_cpu = {
    cores = 4  # More cores
  }

  vm_mem = {
    dedicated = 4096  # More memory
  }

  vm_disk = {
    scsi0 = {
      size = 64  # Larger base disk
      # ...
    }
  }
}
```

## Using the Template

Once created, use the template for cloning:

### With Single VM Example

```hcl
# In terraform/deployments/examples/single-vm/main.tf
module "my_vm" {
  source = "../../../modules/vm"

  vm_type = "clone"
  src_clone = {
    datastore_id = "local-lvm"
    tpl_id       = 2006  # From this template
  }
  # ...
}
```

### With VM Cluster Example

```hcl
# In terraform/deployments/examples/microk8s-cluster/main.tf
module "cluster" {
  source = "../../../modules/vm-cluster"

  template_id = 2006  # From this template
  # ...
}
```

## Image Download Verification

For production use, always verify image checksums:

```bash
# Get Ubuntu checksum
curl -s https://cloud-images.ubuntu.com/jammy/current/SHA256SUMS | grep cloudimg-amd64.img
```

Add to `terraform.tfvars`:

```hcl
cloud_image_checksum = "sha256:abc123def456..."
```

## Migration from Shell Script

If you're currently using `scripts/build-template.sh`, you can replace it with this Terraform approach:

### Before (Shell Script + Timer)

```bash
# Cron job or systemd timer
0 2 * * 0 /path/to/build-template.sh --img /var/lib/vz/template/iso/ubuntu.img
```

### After (Terraform)

```bash
# One-time or scheduled via CI/CD
tofu apply -auto-approve
```

**Benefits**:
- ✅ No manual downloads
- ✅ Version controlled configuration
- ✅ Idempotent operations
- ✅ Integration with Terraform Cloud/Scalr

## Troubleshooting

### SSH Connection Failed

**Error**: `Error creating VM: SSH connection failed` or `Permission denied (publickey)`

**Solution**:

1. **Verify SSH agent is running and has keys loaded:**
   ```bash
   ssh-add -l  # List loaded keys
   ssh-add ~/.ssh/id_rsa  # Add key if needed
   ```

2. **Test direct SSH access:**
   ```bash
   ssh terraform@proxmox-host "echo 'SSH working'"
   # Should return: SSH working
   ```

3. **Check SSH user permissions:**
   ```bash
   # SSH user needs permissions to manage VMs
   # Typically: terraform user or root
   # See: docs/terraform/proxmox-terraform-user.md
   ```

4. **Verify provider SSH configuration:**
   ```hcl
   provider "proxmox" {
     # ...
     ssh {
       agent    = true
       username = "terraform"  # Must match actual SSH user
     }
   }
   ```

### Download Fails

**Error**: `Failed to download image`

**Solution**:
1. Check network connectivity: `curl -I https://cloud-images.ubuntu.com/...`
2. Verify URL is correct and image exists
3. Check Proxmox node has internet access
4. Verify SSH access (download happens on Proxmox host)

### Template Already Exists

**Error**: `VM 2006 already exists`

**Solution**:
1. Change `template_id` in `terraform.tfvars`
2. Or delete existing template: `ssh root@proxmox "qm destroy 2006"`

### Insufficient Storage

**Error**: `Datastore full`

**Solution**:
1. Check datastore space: `pvesm status`
2. Clean up old images: `ls /var/lib/vz/template/iso/`
3. Use different datastore with more space

## Maintenance

### Updating Templates

To update with latest cloud image:

```bash
# Taint the template to force recreation
tofu taint 'module.ubuntu_template.proxmox_virtual_environment_vm.pve_vm'

# Apply to download new image and recreate template
tofu apply
```

### Scheduled Updates

Integrate with CI/CD for weekly updates:

```yaml
# GitHub Actions example
name: Update VM Templates
on:
  schedule:
    - cron: '0 2 * * 0'  # Sunday 2 AM
jobs:
  update:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: opentofu/setup-opentofu@v1
      - run: |
          cd terraform/deployments/examples/template-from-url
          tofu init
          tofu apply -auto-approve
```

## Related Examples

- **[template-from-file](../template-from-file/)** - Create template from existing image file
- **[single-vm](../single-vm/)** - Clone VMs from this template
- **[microk8s-cluster](../microk8s-cluster/)** - Deploy clusters using this template

## Additional Resources

- [Proxmox VM Provisioning Guide](../../../../docs/terraform/proxmox-vm-provisioning-guide.md)
- [VM Module Documentation](../../../modules/vm/README.md)
- [Ubuntu Cloud Images](https://cloud-images.ubuntu.com/)
- [Debian Cloud Images](https://cloud.debian.org/images/cloud/)
