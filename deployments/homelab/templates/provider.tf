# =============================================================================
# = Proxmox Provider Configuration ============================================
# =============================================================================
# This provider configuration is injected by Scalr provider configurations.
# Scalr will inject: endpoint, insecure, api_token, ssh.agent/ssh.private_key
#
# IMPORTANT: Template creation requires SSH access to the Proxmox host
# for image import operations.

provider "proxmox" {
  # All configuration injected by Scalr provider configuration (proxmox-nexus, etc.)
  # The provider block MUST exist for Scalr to inject configuration
}
