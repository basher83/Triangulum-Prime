# ============================================================================
# DigitalOcean Droplets Configuration
# ============================================================================
#
# This workspace manages DigitalOcean droplets for:
# - Testing and development
# - CI/CD runners
# - Jump hosts
# - Temporary workloads
#

locals {
  region        = var.region
  droplet_size  = var.droplet_size
  droplet_count = var.droplet_count

  tags = merge(
    var.default_tags,
    {
      workspace = "digitalocean-droplets"
      managed   = "scalr"
    }
  )
}

# Example: Create droplets
# resource "digitalocean_droplet" "web" {
#   count  = local.droplet_count
#   image  = "ubuntu-22-04-x64"
#   name   = "web-${count.index + 1}"
#   region = local.region
#   size   = local.droplet_size
#
#   tags = local.tags
# }

output "droplet_summary" {
  description = "Summary of DigitalOcean droplets"
  value = {
    region        = local.region
    size          = local.droplet_size
    count         = local.droplet_count
  }
}
