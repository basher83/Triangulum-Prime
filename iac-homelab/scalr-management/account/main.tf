# Global IAM, policies, and credentials management for Scalr account
# This file will contain account-level resources and configurations
# scalr-management/account/main.tf
resource "scalr_variable" "global_tags" {
  key        = "TF_VAR_default_tags"
  value      = jsonencode({
    Environment = "managed-by-scalr"
    Team        = "homelab"
  })
  category   = "shell"
  account_id = var.scalr_account_id
  final      = true
}

resource "scalr_provider_configuration" "proxmox_homelab" {
  name       = "proxmox-homelab"
  account_id = var.scalr_account_id
  custom {
    provider_name = "bgp/proxmox"
    argument {
      name  = "pm_api_url"
      value = var.proxmox_api_url
    }
    argument {
      name  = "pm_api_token_id"
      value = var.proxmox_token_id
    }
    argument {
      name  = "pm_api_token_secret"
      value = var.proxmox_token_secret
      sensitive = true
    }
  }
}