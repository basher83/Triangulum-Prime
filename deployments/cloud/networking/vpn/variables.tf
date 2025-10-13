# ============================================================================
# Variables
# ============================================================================

variable "homelab_public_ip" {
  description = "Homelab public IP for VPN endpoint"
  type        = string
  default     = "0.0.0.0"
  sensitive   = true
}

variable "default_tags" {
  description = "Default tags applied to all resources"
  type        = map(string)
  default = {
    environment = "cloud"
  }
}
