# ============================================================================
# Scalr Provider Configurations
# ============================================================================
#
# Provider configurations are account-scoped credentials and settings that can
# be shared across multiple environments and workspaces. This eliminates the
# need to duplicate provider credentials in each workspace.
#
# These configurations can be:
# - Set as default for specific environments
# - Referenced explicitly in workspaces
# - Overridden at the workspace level if needed

# ============================================================================
# Proxmox Provider Configurations (Multi-Cluster Support)
# ============================================================================
#
# Dynamically creates a provider configuration for each Proxmox cluster
# defined in var.proxmox_clusters. Each cluster gets a provider config named
# "proxmox-{cluster-name}" that can be referenced in environment YAML files.
#
# Example: If you define clusters "pve-prod", "pve-dev", "pve-lab", you'll get:
#   - proxmox-pve-prod
#   - proxmox-pve-dev
#   - proxmox-pve-lab

resource "scalr_provider_configuration" "proxmox_clusters" {
  for_each = var.proxmox_clusters

  name                   = "proxmox-${each.key}"
  account_id             = var.account_id
  export_shell_variables = false  # Custom providers don't support shell variable export
  # Link to environments so workspaces in those environments can use this provider config
  environments = [for env in scalr_environment.environments : env.id]

  custom {
    provider_name = "bpg/proxmox"

    # Endpoint (required)
    argument {
      name        = "endpoint"
      value       = each.value.endpoint
      description = "Proxmox VE API endpoint for ${each.key}"
    }

    # Insecure SSL (optional, default: false)
    dynamic "argument" {
      for_each = each.value.insecure != null ? [1] : []
      content {
        name        = "insecure"
        value       = tostring(each.value.insecure)
        description = "Allow insecure SSL connections"
      }
    }

    # SSH Agent configuration (optional)
    # Use agent = true for local development (default)
    dynamic "argument" {
      for_each = each.value.ssh_agent != null ? [1] : []
      content {
        name        = "ssh.agent"
        value       = tostring(each.value.ssh_agent)
        description = "Enable SSH agent for Proxmox connections"
      }
    }

    # SSH Private Key configuration (for CI/CD pipelines)
    # Use this when SSH agent is not available (ssh_agent = false)
    # Private key must be unencrypted and in PEM format
    # Set via var.proxmox_ssh_key (from terraform.auto.tfvars)
    dynamic "argument" {
      for_each = each.value.ssh_agent == false && var.proxmox_ssh_key != null ? [1] : []
      content {
        name        = "ssh.private_key"
        value       = var.proxmox_ssh_key
        description = "SSH private key for Proxmox connections (CI/CD)"
        sensitive   = true
      }
    }

    # SSH Username configuration (required for template operations)
    # This username is used for SSH connections to Proxmox hosts for image import
    # Default: "terraform" - ensure this user exists on all Proxmox hosts
    # with appropriate sudo permissions for qm/pvesm commands
    dynamic "argument" {
      for_each = each.value.ssh_agent != null || var.proxmox_ssh_key != null ? [1] : []
      content {
        name        = "ssh.username"
        value       = "terraform"
        description = "SSH username for Proxmox host connections"
      }
    }

    # API Token authentication (recommended for production)
    # Format: "username@realm!tokenid=uuid"
    # Example: "terraform@pve!provider=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
    dynamic "argument" {
      for_each = each.value.api_token != null ? [1] : []
      content {
        name        = "api_token"
        value       = each.value.api_token
        description = "Proxmox API token (format: username@realm!tokenid=uuid)"
        sensitive   = true
      }
    }

    # Username/Password authentication (alternative for dev/testing)
    dynamic "argument" {
      for_each = each.value.username != null ? [1] : []
      content {
        name        = "username"
        value       = each.value.username
        description = "Proxmox username (format: username@realm)"
        sensitive   = true
      }
    }

    dynamic "argument" {
      for_each = each.value.password != null ? [1] : []
      content {
        name        = "password"
        value       = each.value.password
        description = "Proxmox password"
        sensitive   = true
      }
    }
  }
}

# ============================================================================
# DigitalOcean Provider Configuration
# ============================================================================

resource "scalr_provider_configuration" "digitalocean" {
  count = var.digitalocean_token != null ? 1 : 0

  name                   = "digitalocean"
  account_id             = var.account_id
  export_shell_variables = false
  environments           = [for env in scalr_environment.environments : env.id]

  custom {
    provider_name = "digitalocean/digitalocean"
    argument {
      name        = "token"
      value       = var.digitalocean_token
      description = "DigitalOcean API token"
      sensitive   = true
    }

    dynamic "argument" {
      for_each = var.digitalocean_spaces_access_key != null ? [1] : []
      content {
        name        = "spaces_access_key_id"
        value       = var.digitalocean_spaces_access_key
        description = "DigitalOcean Spaces access key ID"
        sensitive   = true
      }
    }

    dynamic "argument" {
      for_each = var.digitalocean_spaces_secret_key != null ? [1] : []
      content {
        name        = "spaces_secret_key"
        value       = var.digitalocean_spaces_secret_key
        description = "DigitalOcean Spaces secret key"
        sensitive   = true
      }
    }
  }
}

# ============================================================================
# Hetzner Provider Configuration
# ============================================================================

resource "scalr_provider_configuration" "hetzner" {
  count = var.hetzner_token != null ? 1 : 0

  name                   = "hetzner"
  account_id             = var.account_id
  export_shell_variables = false
  environments           = [for env in scalr_environment.environments : env.id]

  custom {
    provider_name = "hetznercloud/hcloud"
    argument {
      name        = "token"
      value       = var.hetzner_token
      description = "Hetzner Cloud API token"
      sensitive   = true
    }
  }
}

# ============================================================================
# Infisical Provider Configuration
# ============================================================================

resource "scalr_provider_configuration" "infisical" {
  count = var.infisical_client_id != null ? 1 : 0

  name                   = "infisical"
  account_id             = var.account_id
  export_shell_variables = false
  environments           = [for env in scalr_environment.environments : env.id]

  custom {
    provider_name = "infisical/infisical"
    argument {
      name        = "host"
      value       = var.infisical_host
      description = "Infisical API host URL"
    }
    argument {
      name        = "client_id"
      value       = var.infisical_client_id
      description = "Infisical machine identity client ID"
      sensitive   = true
    }
    argument {
      name        = "client_secret"
      value       = var.infisical_client_secret
      description = "Infisical machine identity client secret"
      sensitive   = true
    }
  }
}

# ============================================================================
# Dynamic Provider Configurations (from YAML)
# ============================================================================
#
# This section can be used to define additional provider configurations
# from YAML files if needed in the future. Commented out for now since
# we're using explicit configurations above.

# resource "scalr_provider_configuration" "provider_configs" {
#   for_each = local.provider_configs
#
#   name       = each.key
#   account_id = var.account_id
#
#   custom {
#     provider_name = each.value.provider_name
#     dynamic "argument" {
#       for_each = each.value.arguments
#       content {
#         name        = argument.value.name
#         value       = argument.value.value
#         description = try(argument.value.description, null)
#         sensitive   = try(argument.value.sensitive, false)
#       }
#     }
#   }
# }
