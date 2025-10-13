# ============================================================================
# Terraform/OpenTofu Configuration
# ============================================================================
#
# Workspace: cloud/digitalocean-droplets
# Manages: DigitalOcean droplets for testing and development
#

terraform {
  required_version = ">= 1.8.0"

  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

provider "digitalocean" {
  # Configuration provided by Scalr
}
