# ============================================================================
# Variables
# ============================================================================

variable "nomad_version" {
  description = "HashiCorp Nomad version to deploy"
  type        = string
  default     = "1.7.0"
}

variable "consul_version" {
  description = "HashiCorp Consul version to deploy"
  type        = string
  default     = "1.17.0"
}

variable "server_count" {
  description = "Number of server nodes (Nomad + Consul servers)"
  type        = string
  default     = "3"
}

variable "client_count" {
  description = "Number of client nodes (Nomad clients)"
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
