# ============================================================================
# Terraform/OpenTofu Configuration
# ============================================================================
#
# Workspace: cloud/hetzner-instances
# Manages: Hetzner Cloud instances for cost-effective compute
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
