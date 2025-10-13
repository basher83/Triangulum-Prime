# ============================================================================
# Scalr Environments
# ============================================================================
#
# Environments in Scalr provide logical isolation for workspaces and allow
# different teams/projects to work independently. Each environment can have:
# - Default provider configurations
# - Policy groups (OPA/Sentinel policies)
# - Environment-level variables
# - Separate access controls (if using teams)
#
# For homelab use, environments help organize infrastructure by purpose:
# - homelab: On-premise Proxmox infrastructure
# - cloud: Cloud provider resources (DO, Hetzner, AWS, etc.)

resource "scalr_environment" "environments" {
  for_each = local.environments

  name                    = each.value.name
  account_id              = var.account_id
  cost_estimation_enabled = each.value.cost_estimation_enabled

  # Note: default_provider_configurations requires special permissions in Scalr
  # For solo/homelab use, it's simpler to let workspaces reference provider configs directly
  # If you need environment-level defaults, contact Scalr support to enable this feature
  # default_provider_configurations = [
  #   for provider_config_name in each.value.default_provider_configs :
  #   local.provider_config_map[provider_config_name]
  #   if contains(keys(local.provider_config_map), provider_config_name)
  # ]

  # Apply policy groups if specified
  # policy_groups = each.value.policy_groups
}

# ============================================================================
# Environment-Level Variables
# ============================================================================
#
# Define variables that apply to all workspaces within an environment.
# These are useful for:
# - Common tags/labels
# - Environment-specific configuration
# - Shared secrets from Infisical or Vault

# Example: Default tags for homelab environment
resource "scalr_variable" "homelab_default_tags" {
  count = contains(keys(local.environments), "homelab") ? 1 : 0

  key        = "TF_VAR_default_tags"
  value      = jsonencode({
    managed_by  = "scalr"
    environment = "homelab"
    project     = "triangulum-prime"
  })
  category       = "shell"
  account_id     = var.account_id
  environment_id = scalr_environment.environments["homelab"].id
  description    = "Default tags applied to all homelab resources"
}

# Example: Proxmox datacenter variable
resource "scalr_variable" "homelab_datacenter" {
  count = contains(keys(local.environments), "homelab") ? 1 : 0

  key            = "TF_VAR_datacenter"
  value          = "homelab-dc1"
  category       = "shell"
  account_id     = var.account_id
  environment_id = scalr_environment.environments["homelab"].id
  description    = "Proxmox datacenter name"
}
