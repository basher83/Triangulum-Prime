# ============================================================================
# Variables
# ============================================================================

variable "default_tags" {
  description = "Default tags applied to all resources"
  type        = map(string)
  default = {
    environment = "cloud"
  }
}
