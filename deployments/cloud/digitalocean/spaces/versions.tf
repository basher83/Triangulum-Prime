# ============================================================================
# Terraform/OpenTofu Configuration
# ============================================================================
#
# Workspace: cloud/digitalocean-spaces
# Manages: DigitalOcean Spaces for object storage and backups
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
  # Includes spaces_access_key and spaces_secret_key
}
