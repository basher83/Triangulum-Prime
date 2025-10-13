# ============================================================================
# Terraform/OpenTofu Configuration
# ============================================================================
#
# Workspace: homelab/nomad-consul-cluster
# Manages: HashiCorp Nomad scheduler with Consul service mesh
#

terraform {
  required_version = ">= 1.8.0"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.70"
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
