# ============================================================================
# Variables
# ============================================================================

variable "vm_template_id" {
  description = "Proxmox VM template ID to clone from"
  type        = string
  default     = "2006"
}

variable "vm_count" {
  description = "Number of single-purpose VMs to create"
  type        = string
  default     = "3"
}

variable "proxmox_node" {
  description = "Proxmox node to deploy VMs on"
  type        = string
  default     = "pve-01"
}

variable "default_tags" {
  description = "Default tags applied to all resources"
  type        = map(string)
  default = {
    managed_by  = "scalr"
    environment = "homelab"
  }
}
