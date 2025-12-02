# ============================================================================
# Terraform/OpenTofu Configuration
# ============================================================================
#
# Workspace: homelab/lxc-containers
# Manages: Proxmox LXC containers for lightweight services
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
