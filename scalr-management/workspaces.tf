# ============================================================================
# Scalr Workspaces
# ============================================================================
#
# Workspaces in Scalr represent individual Terraform/OpenTofu configurations.
# Each workspace:
# - Maps to a specific infrastructure deployment
# - Can be VCS-backed (GitHub) or CLI-driven
# - Has its own state file
# - Can have specific variables, hooks, and run configurations
#
# Workspaces are defined in YAML files under data/environments/
# and are automatically created here using for_each.

# ============================================================================
# Data Source: VCS Provider
# ============================================================================

data "scalr_vcs_provider" "github" {
  count      = var.vcs_provider_id != null ? 1 : 0
  id         = var.vcs_provider_id
  account_id = var.account_id
}

# ============================================================================
# Data Source: Agent Pool
# ============================================================================

data "scalr_agent_pool" "default" {
  count          = var.agent_pool_name != null && var.agent_pool_environment != null ? 1 : 0
  name           = var.agent_pool_name
  account_id     = var.account_id
  environment_id = scalr_environment.environments[var.agent_pool_environment].id
}

# ============================================================================
# Workspace Resources
# ============================================================================

resource "scalr_workspace" "workspaces" {
  for_each = local.workspaces

  name           = each.value.name
  environment_id = scalr_environment.environments[each.value.environment_name].id
  auto_apply     = each.value.auto_apply

  # Terraform/OpenTofu version
  terraform_version = each.value.terraform_version

  # Execution mode: "remote" (run in Scalr) or "local" (run on local machine)
  execution_mode = each.value.execution_mode

  # IaC platform: "opentofu" or "terraform"
  iac_platform = each.value.iac_platform

  # Working directory within the VCS repository
  working_directory = each.value.working_directory

  # Variable files to load (e.g., terraform.tfvars, *.auto.tfvars)
  var_files = each.value.var_files

  # VCS provider (required if using vcs_repo)
  vcs_provider_id = each.value.vcs_repo != null && var.vcs_provider_id != null ? data.scalr_vcs_provider.github[0].id : null

  # Agent pool (if using self-hosted agents)
  # Priority: workspace-specific agent_pool_id from YAML > default agent pool from variable (if environment matches)
  agent_pool_id = each.value.agent_pool_id != null ? each.value.agent_pool_id : (
    var.agent_pool_name != null && var.agent_pool_environment != null && each.value.environment_name == var.agent_pool_environment ? data.scalr_agent_pool.default[0].id : null
  )

  # Run operation mode (optional)
  # run_operation_mode = each.value.run_operation_mode

  # VCS repository configuration
  # Note: 'path' has been deprecated - use working_directory at workspace level instead
  dynamic "vcs_repo" {
    for_each = each.value.vcs_repo != null && var.vcs_provider_id != null ? [each.value.vcs_repo] : []
    content {
      identifier = vcs_repo.value.identifier
      branch     = vcs_repo.value.branch
      # Note: trigger_patterns and trigger_prefixes are mutually exclusive
      # If trigger_patterns is set, trigger_prefixes will be null
      trigger_patterns = vcs_repo.value.trigger_patterns
      trigger_prefixes = vcs_repo.value.trigger_prefixes
    }
  }

  # Provider configurations (Proxmox, DigitalOcean, Hetzner, etc.)
  # Each workspace can have multiple provider configurations attached
  dynamic "provider_configuration" {
    for_each = each.value.provider_configurations
    content {
      id    = provider_configuration.value.id
      alias = provider_configuration.value.alias
    }
  }

  # Hooks configuration (pre-plan, post-plan, pre-apply, post-apply)
  dynamic "hooks" {
    for_each = each.value.hooks != null ? [each.value.hooks] : []
    content {
      pre_plan   = try(hooks.value.pre_plan, null)
      post_plan  = try(hooks.value.post_plan, null)
      pre_apply  = try(hooks.value.pre_apply, null)
      post_apply = try(hooks.value.post_apply, null)
    }
  }
}

# ============================================================================
# Workspace Variables (Terraform Variables)
# ============================================================================

resource "scalr_variable" "workspace_variables" {
  for_each = merge([
    for ws_key, ws in local.workspaces : {
      for var in ws.variables :
      "${ws_key}/${var.key}" => {
        workspace_key = ws_key
        key           = var.key
        value         = var.value
        category      = try(var.category, "terraform")
        description   = try(var.description, "")
        sensitive     = try(var.sensitive, false)
        final         = try(var.final, false)
        hcl           = try(var.hcl, false)
      }
    }
  ]...)

  account_id   = var.account_id
  workspace_id = scalr_workspace.workspaces[each.value.workspace_key].id
  key          = each.value.key
  value        = each.value.value
  category     = each.value.category
  description  = each.value.description
  sensitive    = each.value.sensitive
  final        = each.value.final
  hcl          = each.value.hcl
}

# ============================================================================
# Workspace Environment Variables (Shell Variables)
# ============================================================================

resource "scalr_variable" "workspace_env_variables" {
  for_each = merge([
    for ws_key, ws in local.workspaces : {
      for var in ws.environment_variables :
      "${ws_key}/${var.key}" => {
        workspace_key = ws_key
        key           = var.key
        value         = var.value
        description   = try(var.description, "")
        sensitive     = try(var.sensitive, false)
        final         = try(var.final, false)
      }
    }
  ]...)

  account_id   = var.account_id
  workspace_id = scalr_workspace.workspaces[each.value.workspace_key].id
  key          = each.value.key
  value        = each.value.value
  category     = "shell"
  description  = each.value.description
  sensitive    = each.value.sensitive
  final        = each.value.final
}
