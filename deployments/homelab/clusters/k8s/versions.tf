# ============================================================================
# Terraform/OpenTofu Configuration
# ============================================================================
#
# Workspace: homelab/k8s-cluster
# Manages: Kubernetes cluster on Proxmox using MicroK8s
#

terraform {
  required_version = ">= 1.8.0"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.85"
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
