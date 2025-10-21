# =============================================================================
# = Proxmox Provider Configuration ============================================
# =============================================================================
# This provider block is required for Scalr to inject the custom provider
# configuration. The actual values are managed by Scalr provider configuration
# and will be injected at runtime.
#
# DO NOT set values here - they come from the Scalr provider configuration
# attached to the workspace (proxmox-nexus, proxmox-matrix, or proxmox-quantum).

provider "proxmox" {
  # Configuration from workspace variables
  endpoint = var.proxmox_endpoint
  username = var.proxmox_username
  password = var.proxmox_password
  insecure = var.proxmox_insecure

  # SSH configuration for template operations
  ssh {
    agent       = var.proxmox_ssh_agent
    username    = var.proxmox_ssh_username
    private_key = var.proxmox_ssh_key
  }
}
