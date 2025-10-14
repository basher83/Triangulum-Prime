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
  # Configuration values are injected by Scalr custom provider configuration:
  # - endpoint: Proxmox API endpoint (e.g., https://192.168.30.30:8006)
  # - api_token: Proxmox API authentication token
  # - insecure: Allow insecure SSL connections (optional)
  # - ssh configuration: For template operations
}
