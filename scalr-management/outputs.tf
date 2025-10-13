# ============================================================================
# Environment Outputs
# ============================================================================

output "environments" {
  description = "Map of environment names to their IDs"
  value = {
    for name, env in scalr_environment.environments :
    name => {
      id   = env.id
      name = env.name
    }
  }
}

output "environment_ids" {
  description = "Map of environment names to IDs (simple format)"
  value = {
    for name, env in scalr_environment.environments :
    name => env.id
  }
}

# ============================================================================
# Workspace Outputs
# ============================================================================

output "workspaces" {
  description = "Map of workspace keys to their details"
  value = {
    for key, ws in scalr_workspace.workspaces :
    key => {
      id             = ws.id
      name           = ws.name
      environment_id = ws.environment_id
      auto_apply     = ws.auto_apply
      execution_mode = ws.execution_mode
    }
  }
}

output "workspace_ids" {
  description = "Map of workspace keys to IDs (simple format)"
  value = {
    for key, ws in scalr_workspace.workspaces :
    key => ws.id
  }
}

output "workspaces_by_environment" {
  description = "Workspaces grouped by environment name"
  value = {
    for env_name in keys(local.environments) :
    env_name => {
      for key, ws in scalr_workspace.workspaces :
      ws.name => {
        id             = ws.id
        name           = ws.name
        auto_apply     = ws.auto_apply
        execution_mode = ws.execution_mode
      }
      if can(regex("^${env_name}/", key))
    }
  }
}

# ============================================================================
# Provider Configuration Outputs
# ============================================================================

output "provider_configurations" {
  description = "Map of all provider configuration names to their details"
  sensitive   = true
  value = merge(
    # Proxmox clusters
    {
      for name, config in scalr_provider_configuration.proxmox_clusters :
      "proxmox-${name}" => {
        id   = config.id
        name = config.name
      }
    },
    # DigitalOcean
    var.digitalocean_token != null ? {
      "digitalocean" = {
        id   = scalr_provider_configuration.digitalocean[0].id
        name = scalr_provider_configuration.digitalocean[0].name
      }
    } : {},
    # Hetzner
    var.hetzner_token != null ? {
      "hetzner" = {
        id   = scalr_provider_configuration.hetzner[0].id
        name = scalr_provider_configuration.hetzner[0].name
      }
    } : {},
    # Infisical
    var.infisical_client_id != null ? {
      "infisical" = {
        id   = scalr_provider_configuration.infisical[0].id
        name = scalr_provider_configuration.infisical[0].name
      }
    } : {}
  )
}

output "provider_configuration_ids" {
  description = "Map of provider configuration names to IDs (simple format)"
  sensitive   = true
  value       = local.provider_config_map
}

# ============================================================================
# Summary Output
# ============================================================================

output "summary" {
  description = "Summary of managed Scalr resources"
  sensitive   = true
  value = {
    environments_count            = length(scalr_environment.environments)
    workspaces_count              = length(scalr_workspace.workspaces)
    provider_configurations_count = length(local.provider_config_map)
    proxmox_clusters_count        = length(var.proxmox_clusters)

    environments     = [for name in keys(scalr_environment.environments) : name]
    proxmox_clusters = [for name in keys(var.proxmox_clusters) : "proxmox-${name}"]
    provider_configs = keys(local.provider_config_map)

    workspaces_by_env = {
      for env_name in keys(local.environments) :
      env_name => [
        for key, ws in scalr_workspace.workspaces :
        ws.name if can(regex("^${env_name}/", key))
      ]
    }
  }
}
