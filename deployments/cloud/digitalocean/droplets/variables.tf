# ============================================================================
# Variables
# ============================================================================

variable "region" {
  description = "DigitalOcean region"
  type        = string
  default     = "nyc3"
}

variable "droplet_size" {
  description = "Droplet size slug"
  type        = string
  default     = "s-1vcpu-1gb"
}

variable "droplet_count" {
  description = "Number of droplets to create"
  type        = string
  default     = "2"
}

variable "default_tags" {
  description = "Default tags applied to all resources"
  type        = map(string)
  default = {
    environment = "cloud"
  }
}
