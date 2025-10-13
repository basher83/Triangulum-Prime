# ============================================================================
# Base Infrastructure Configuration
# ============================================================================
#
# This workspace manages foundational Proxmox infrastructure:
# - Network bridges and VLANs
# - Storage pools and mount points
# - Firewall rules and security groups
# - DNS and DHCP configuration
# - Shared resources and templates
#

# Example: Get Proxmox node information
data "proxmox_virtual_environment_nodes" "available_nodes" {
  provider = proxmox.nexus
}

# Example output
output "cluster_nodes" {
  description = "Available Proxmox nodes"
  value = {
    nexus = data.proxmox_virtual_environment_nodes.available_nodes.names
  }
}

# TODO: Add your base infrastructure resources here
# Examples:
# - Network configuration
# - Storage configuration
# - Firewall rules
# - Shared VM templates
