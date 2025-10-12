# Scalr workspace configuration for Proxmox single VMs
# scalr-management/environments/homelab/workspaces/proxmox-single-vms.tf
resource "scalr_workspace" "proxmox_single_vms" {
  name           = "proxmox-single-vms"
  environment_id = scalr_environment.homelab.id
  
  vcs_provider_id = data.scalr_vcs_provider.github.id
  vcs_repo {
    identifier = "your-org/iac-homelab"
    branch     = "main"
    path       = "deployments/homelab/proxmox/single-vms"
  }
  
  terraform_version = "1.8.0"  # Will migrate to OpenTofu
  execution_mode    = "local"   # For testing, then "remote"
  
  var_files = [
    "homelab.tfvars"
  ]
  
  # Workspace-specific variables
  variable {
    key      = "vm_template"
    value    = "ubuntu-22.04-template"
    category = "terraform"
  }
}