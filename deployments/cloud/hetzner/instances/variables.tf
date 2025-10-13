# ============================================================================
# Variables
# ============================================================================

variable "location" {
  description = "Hetzner datacenter location"
  type        = string
  default     = "nbg1"
}

variable "server_type" {
  description = "Hetzner server type"
  type        = string
  default     = "cx11"
}

variable "instance_count" {
  description = "Number of instances"
  type        = string
  default     = "1"
}

variable "default_tags" {
  description = "Default tags applied to all resources"
  type        = map(string)
  default = {
    environment = "cloud"
  }
}
