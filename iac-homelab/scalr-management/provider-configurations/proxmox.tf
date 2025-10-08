# Scalr provider configuration for Proxmox
terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = "0.84.1"
    }
  }
}

provider "proxmox" {
  endpoint = var.virtual_environment_endpoint
  username = var.virtual_environment_username
  password = var.virtual_environment_password
  insecure = var.virtual_environment_insecure
  ssh {
    agent = var.virtual_environment_ssh_agent
  }
}
