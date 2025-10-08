# Scalr environment configuration for homelab
# Contains scalr_environment resource definition
# scalr-management/environments/homelab/environment.tf
resource "scalr_environment" "homelab" {
  name       = "homelab"
  account_id = var.scalr_account_id
  
  default_provider_configurations = [
    scalr_provider_configuration.proxmox_homelab.id
  ]
  
  policy_groups = [
    scalr_policy_group.security_baseline.id
  ]
}

resource "scalr_variable" "homelab_region" {
  key            = "TF_VAR_datacenter"
  value          = "homelab-dc1"
  category       = "shell"
  environment_id = scalr_environment.homelab.id
}