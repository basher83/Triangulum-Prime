# =============================================================================
# = Template Creation from Existing File Example ==============================
# =============================================================================
# This example demonstrates creating a Proxmox VM template from an existing
# cloud image file already present on the Proxmox storage.
#
# Features:
# - Uses pre-downloaded cloud images
# - Minimal configuration (templates rely on module defaults)
# - Compatible with shell script workflows (build-template.sh)
#
# Use Case: When images are managed outside Terraform (manual downloads, timers)
#
# IMPORTANT: Template creation requires SSH access to the Proxmox host.
# See provider.tf for SSH configuration details.
#
# This example follows DRY principles by:
# - Only specifying template-specific overrides
# - Not repeating module defaults (see terraform/modules/vm/DEFAULTS.md)
# - Keeping configuration minimal - templates are refined during cloning

# =============================================================================
# = Template Creation from Existing File ======================================
# =============================================================================

module "ubuntu_template" {
  source = "../../../modules/vm"

  # Required: VM type and Proxmox node
  vm_type  = "image"
  pve_node = var.proxmox_node

  # Override: Mark as template (cannot be started, used for cloning)
  vm_template = true

  # Required: Reference existing cloud image file
  # File must already exist on Proxmox storage
  src_file = {
    datastore_id = var.cloud_image_datastore
    file_name    = var.cloud_image_filename
    # No URL - file already exists on Proxmox
  }

  # Required: VM identification
  vm_name        = var.template_name
  vm_id          = var.template_id
  vm_description = var.template_description
  vm_tags        = var.template_tags

  # Templates use module defaults for CPU/memory
  # These will be customized during cloning

  # Required: EFI disk for UEFI boot
  vm_efi_disk = {
    datastore_id = var.datastore
    # file_format, type have sensible defaults
  }

  # Required: Disk configuration (will be imported from cloud image)
  vm_disk = {
    scsi0 = {
      datastore_id = var.datastore
      size         = var.disk_size
      main_disk    = true
      # file_format, iothread, ssd, discard all have optimal defaults
    }
  }

  # Required: Network configuration (minimal, will be configured during clone)
  vm_net_ifaces = {
    net0 = {
      bridge    = var.network_bridge
      ipv4_addr = "dhcp"
      # firewall defaults to false - no need to specify
    }
  }

  # Required: Cloud-init configuration
  vm_init = {
    datastore_id = var.cloud_init_datastore
    # interface defaults to "ide2" - no need to specify

    dns = {
      servers = var.dns_servers
    }

    # Note: User configuration not needed for template
    # It will be set during cloning
  }

  # Override: Templates don't start
  vm_start = {
    on_deploy = false
    on_boot   = false
    # order, up_delay, down_delay default to 0 - no need to specify
  }

  # Note: The following are NOT specified because module defaults are optimal:
  # - vm_bios (defaults to "ovmf" for UEFI)
  # - vm_machine (defaults to "q35" modern chipset)
  # - vm_os (defaults to "l26" for Linux 2.6+)
  # - vm_cpu (defaults to 2 cores, host type)
  # - vm_mem (defaults to 2048 MB)
  # - vm_agent (defaults to enabled)
  # Templates use minimal resources - customize during cloning
  # See terraform/modules/vm/DEFAULTS.md for complete defaults reference
}

# =============================================================================
# = Outputs ===================================================================
# =============================================================================

output "template_id" {
  description = "Template VM ID for use in clone operations"
  value       = module.ubuntu_template.vm_id
}

output "template_name" {
  description = "Template VM name"
  value       = module.ubuntu_template.vm_name
}

output "template_node" {
  description = "Proxmox node where template is stored"
  value       = module.ubuntu_template.vm_node
}
