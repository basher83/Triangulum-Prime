# ============================================================================
# YAML Data Loading and Transformation
# ============================================================================

locals {
  # Load all environment YAML files and merge them into a single list
  environments_raw = flatten([
    for env_file in fileset(".", "${var.environments_data_path}/*.yaml") :
    yamldecode(file(env_file))
  ])

  # Transform environments into a map keyed by environment name
  environments = {
    for env in local.environments_raw :
    env.name => {
      name                     = env.name
      default_provider_configs = try(env.default_provider_configs, [])
      policy_groups            = try(env.policy_groups, [])
      workspaces               = try(env.workspaces, [])
    }
  }

  # Flatten all workspaces from all environments
  # Creates a map with key format: "environment-name/workspace-name"
  workspaces_flat = merge([
    for env_name, env in local.environments : {
      for ws in env.workspaces :
      "${env_name}/${ws.name}" => merge(ws, {
        environment_name = env_name
      })
    }
  ]...)

  # Create workspace configurations with all required fields
  workspaces = {
    for key, ws in local.workspaces_flat :
    key => {
      name              = ws.name
      environment_name  = ws.environment_name
      description       = try(ws.description, "")
      auto_apply        = try(ws.auto_apply, false)
      terraform_version = try(ws.terraform_version, null)
      execution_mode    = try(ws.execution_mode, "remote")
      iac_platform      = try(ws.iac_platform, "opentofu")
      var_files         = try(ws.var_files, [])
      # Use working_directory if set, otherwise fall back to vcs_repo.path for backwards compatibility
      working_directory = try(ws.working_directory, try(ws.vcs_repo.path, null))

      # VCS repository configuration
      # Note: 'path' attribute is deprecated in favor of working_directory
      vcs_repo = try(ws.vcs_repo, null) != null ? {
        identifier = ws.vcs_repo.identifier
        branch     = try(ws.vcs_repo.branch, "main")

        # Trigger configuration (trigger_patterns and trigger_prefixes are mutually exclusive)
        # Priority:
        # 1. Use trigger_patterns if explicitly set (supports gitignore-style exclusions)
        # 2. Use trigger_prefixes if explicitly set (simple path list)
        # 3. Default to trigger_prefixes with working_directory
        trigger_patterns = try(ws.vcs_repo.trigger_patterns, null)
        trigger_prefixes = try(ws.vcs_repo.trigger_patterns, null) == null ? (
          try(ws.vcs_repo.trigger_prefixes, null) != null ? ws.vcs_repo.trigger_prefixes : (
            try(ws.working_directory, try(ws.vcs_repo.path, null)) != null ? [try(ws.working_directory, ws.vcs_repo.path)] : null
          )
        ) : null
      } : null

      # Workspace variables
      variables = try(ws.variables, [])

      # Environment variables
      environment_variables = try(ws.environment_variables, [])

      # Hooks
      hooks = try(ws.hooks, null)

      # Run operation mode
      run_operation_mode = try(ws.run_operation_mode, null)

      # Agent pool ID
      agent_pool_id = try(ws.agent_pool_id, null)

      # Provider configurations for this workspace
      # Priority: workspace-specific provider_configs > environment default_provider_configs
      # Logic for aliases:
      # - If workspace has ONLY ONE Proxmox provider: alias = null (no alias needed)
      # - If workspace has MULTIPLE Proxmox providers: alias = cluster name (needed to distinguish)
      # - For non-Proxmox providers: alias = null (only one of each type)
      provider_configurations = try(ws.provider_configs, null) != null ? [
        for provider_name in ws.provider_configs : {
          id = local.provider_config_map[provider_name]
          # No alias needed when workspace specifies only one provider config
          alias = null
        }
        if contains(keys(local.provider_config_map), provider_name)
        ] : [
        for provider_name in local.environments[ws.environment_name].default_provider_configs : {
          id = local.provider_config_map[provider_name]
          # Use alias when inheriting multiple Proxmox providers from environment defaults
          alias = startswith(provider_name, "proxmox-") ? trimprefix(provider_name, "proxmox-") : null
        }
        if contains(keys(local.provider_config_map), provider_name)
      ]
    }
  }

  # Create a map of all provider configuration names to their IDs
  # This allows environments to reference provider configs by name in YAML
  provider_config_map = merge(
    # Proxmox clusters (dynamically created)
    {
      for name, config in scalr_provider_configuration.proxmox_clusters :
      "proxmox-${name}" => config.id
    },
    # DigitalOcean
    var.digitalocean_token != null ? {
      "digitalocean" = scalr_provider_configuration.digitalocean[0].id
    } : {},
    # Hetzner
    var.hetzner_token != null ? {
      "hetzner" = scalr_provider_configuration.hetzner[0].id
    } : {},
    # Infisical
    var.infisical_client_id != null ? {
      "infisical" = scalr_provider_configuration.infisical[0].id
    } : {}
  )
}
