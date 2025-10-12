
terraform {
  required_version = ">= 1.0"

  required_providers {
    proxmox = {
      version = ">= 0.84.1"
      source  = "bpg/proxmox"
    }
  }
}
