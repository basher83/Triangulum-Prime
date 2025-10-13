# ============================================================================
# Variables
# ============================================================================

variable "lxc_template" {
  description = "LXC template to use for containers"
  type        = string
  default     = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
}

variable "proxmox_node" {
  description = "Proxmox node to deploy containers on"
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
