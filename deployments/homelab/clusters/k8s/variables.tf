# ============================================================================
# Variables
# ============================================================================

variable "cluster_size" {
  description = "Total number of K8s nodes (deprecated - use control_plane_count + worker_count)"
  type        = string
  default     = "3"
}

variable "control_plane_count" {
  description = "Number of control plane nodes"
  type        = string
  default     = "1"
}

variable "worker_count" {
  description = "Number of worker nodes"
  type        = string
  default     = "2"
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
