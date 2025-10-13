# ============================================================================
# Variables
# ============================================================================
#
# Variables can be set in the Scalr workspace configuration or passed via
# terraform.tfvars files.

variable "proxmox_node" {
  description = "Primary Proxmox node for infrastructure resources"
  type        = string
  default     = "pve-01"
}

variable "default_tags" {
  description = "Default tags applied to all resources"
  type        = map(string)
  default = {
    managed_by  = "scalr"
    environment = "homelab"
    workspace   = "infra-base"
  }
}
