# ============================================================================
# Terraform/OpenTofu Configuration
# ============================================================================
#
# Workspace: cloud/hetzner-networking
# Manages: Hetzner Cloud networking (private networks, load balancers)
#

terraform {
  required_version = ">= 1.8.0"

  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.45"
    }
  }
}

provider "hcloud" {
  # Configuration provided by Scalr
}
