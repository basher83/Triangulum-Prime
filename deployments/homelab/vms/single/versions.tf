# ============================================================================
# Terraform/OpenTofu Configuration
# ============================================================================
#
# Workspace: homelab/single-vms
# Manages: Single-purpose Proxmox VMs (DNS, monitoring, services, etc.)
#

terraform {
  required_version = ">= 1.8.0"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.88"
    }
  }
}

provider "proxmox" {
  alias = "nexus"
}

provider "proxmox" {
  alias = "matrix"
}

provider "proxmox" {
  alias = "quantum"
}
