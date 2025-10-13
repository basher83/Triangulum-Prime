# ============================================================================
# Terraform/OpenTofu Configuration
# ============================================================================
#
# Workspace: cloud/multi-cloud-vpn
# Manages: Site-to-site VPN between homelab and cloud providers
#

terraform {
  required_version = ">= 1.8.0"

  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.45"
    }
  }
}

provider "digitalocean" {
  # Configuration provided by Scalr
}

provider "hcloud" {
  # Configuration provided by Scalr
}
