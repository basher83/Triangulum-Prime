# ============================================================================
# Variables
# ============================================================================

variable "vault_version" {
  description = "HashiCorp Vault version to deploy"
  type        = string
  default     = "1.15.0"
}

variable "cluster_size" {
  description = "Number of Vault nodes (3 or 5 recommended for HA)"
  type        = string
  default     = "3"
}

variable "proxmox_node" {
  description = "Proxmox node to deploy cluster on"
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
