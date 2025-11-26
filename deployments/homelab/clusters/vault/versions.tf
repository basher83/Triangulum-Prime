# ============================================================================
# Terraform/OpenTofu Configuration
# ============================================================================
#
# Workspace: homelab/vault-cluster
# Manages: HashiCorp Vault cluster for secrets management
#

terraform {
  required_version = ">= 1.8.0"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.86"
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
