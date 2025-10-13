# ============================================================================
# Hetzner Cloud Instances Configuration
# ============================================================================

locals {
  location       = var.location
  server_type    = var.server_type
  instance_count = var.instance_count

  labels = merge(
    var.default_tags,
    {
      workspace = "hetzner-instances"
    }
  )
}

# Example: Create servers
# resource "hcloud_server" "app" {
#   count       = local.instance_count
#   name        = "app-${count.index + 1}"
#   server_type = local.server_type
#   location    = local.location
#   image       = "ubuntu-22.04"
#
#   labels = local.labels
# }

output "instance_summary" {
  description = "Summary of Hetzner instances"
  value = {
    location = local.location
    type     = local.server_type
    count    = local.instance_count
  }
}
