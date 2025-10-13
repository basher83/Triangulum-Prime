# ============================================================================
# DigitalOcean Spaces Configuration
# ============================================================================
#
# This workspace manages DigitalOcean Spaces (S3-compatible object storage):
# - Backup storage
# - Static website hosting
# - Media/asset storage
# - Terraform state backends (for other projects)
#

locals {
  region = var.region

  tags = merge(
    var.default_tags,
    {
      workspace = "digitalocean-spaces"
    }
  )
}

# Example: Create a Space
# resource "digitalocean_spaces_bucket" "backup" {
#   name   = "homelab-backups"
#   region = local.region
#   acl    = "private"
#
#   versioning {
#     enabled = true
#   }
#
#   lifecycle_rule {
#     id      = "cleanup-old-versions"
#     enabled = true
#
#     expiration {
#       days = 90
#     }
#
#     noncurrent_version_expiration {
#       days = 30
#     }
#   }
# }

output "spaces_config" {
  description = "Spaces configuration"
  value = {
    region = local.region
  }
}
