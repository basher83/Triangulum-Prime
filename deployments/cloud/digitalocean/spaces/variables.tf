# ============================================================================
# Variables
# ============================================================================

variable "region" {
  description = "DigitalOcean Spaces region"
  type        = string
  default     = "nyc3"
}

variable "default_tags" {
  description = "Default tags applied to all resources"
  type        = map(string)
  default = {
    environment = "cloud"
  }
}
