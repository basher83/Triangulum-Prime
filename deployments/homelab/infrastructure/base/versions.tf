# ============================================================================
# Terraform/OpenTofu Configuration
# ============================================================================
#
# Workspace: homelab/infra-base
# Manages: Base Proxmox infrastructure, networking, and storage configuration
#

terraform {
  required_version = ">= 1.8.0"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.88"
    }
  }

  # Backend configured in Scalr workspace
  # No need to specify backend block here
}

# ============================================================================
# Provider Configuration
# ============================================================================
#
# Multiple Proxmox clusters are available via Scalr provider configurations:
# - provider.proxmox.nexus (192.168.30.30)
# - provider.proxmox.matrix (192.168.3.5)
# - provider.proxmox.quantum (192.168.10.2)
#
# Use the alias to target specific clusters:
#   resource "proxmox_virtual_environment_vm" "example" {
#     provider = proxmox.nexus
#     ...
#   }

provider "proxmox" {
  alias = "nexus"
  # Configuration provided by Scalr
}

provider "proxmox" {
  alias = "matrix"
  # Configuration provided by Scalr
}

provider "proxmox" {
  alias = "quantum"
  # Configuration provided by Scalr
}
