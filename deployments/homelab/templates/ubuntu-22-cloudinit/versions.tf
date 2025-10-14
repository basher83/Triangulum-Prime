terraform {
  required_version = ">= 1.8"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.84.1" # Pin to 0.84.x - 0.85.0 has template creation bug
    }
  }
}
