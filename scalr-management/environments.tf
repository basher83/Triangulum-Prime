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

  name       = each.value.name
  account_id = var.account_id

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

# Proxmox SSH private key for CI/CD template creation
resource "scalr_variable" "homelab_proxmox_ssh_key" {
  count = contains(keys(local.environments), "homelab") ? 1 : 0

  key            = "proxmox_ssh_key"
  value          = var.proxmox_ssh_key
  category       = "terraform"
  sensitive      = true
  account_id     = var.account_id
  environment_id = scalr_environment.environments["homelab"].id
  description    = "SSH private key for Proxmox template creation (CI/CD)"
}

resource "scalr_variable" "homelab_proxmox_ssh_username" {
  count = contains(keys(local.environments), "homelab") ? 1 : 0

  key            = "proxmox_ssh_username"
  value          = "terraform"
  category       = "terraform"
  sensitive      = false
  account_id     = var.account_id
  environment_id = scalr_environment.environments["homelab"].id
  description    = "SSH username for Proxmox host connections"
}

resource "scalr_variable" "homelab_proxmox_insecure" {
  count = contains(keys(local.environments), "homelab") ? 1 : 0

  key            = "proxmox_insecure"
  value          = "true"
  category       = "terraform"
  sensitive      = false
  account_id     = var.account_id
  environment_id = scalr_environment.environments["homelab"].id
  description    = "Allow insecure SSL connections for self-signed certificates"
}

resource "scalr_variable" "homelab_proxmox_ssh_agent" {
  count = contains(keys(local.environments), "homelab") ? 1 : 0

  key            = "proxmox_ssh_agent"
  value          = "false"
  category       = "terraform"
  sensitive      = false
  account_id     = var.account_id
  environment_id = scalr_environment.environments["homelab"].id
  description    = "Disable SSH agent (using private key instead for CI/CD)"
}
