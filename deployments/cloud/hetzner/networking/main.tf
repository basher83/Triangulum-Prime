# ============================================================================
# Hetzner Cloud Networking Configuration
# ============================================================================

# Example: Private network
# resource "hcloud_network" "private" {
#   name     = "homelab-network"
#   ip_range = "10.0.0.0/16"
#
#   labels = {
#     environment = "cloud"
#     workspace   = "hetzner-networking"
#   }
# }

# Example: Network subnet
# resource "hcloud_network_subnet" "subnet" {
#   network_id   = hcloud_network.private.id
#   type         = "cloud"
#   network_zone = "eu-central"
#   ip_range     = "10.0.1.0/24"
# }

# Example: Load balancer
# resource "hcloud_load_balancer" "lb" {
#   name               = "app-lb"
#   load_balancer_type = "lb11"
#   location           = "nbg1"
#
#   labels = {
#     environment = "cloud"
#   }
# }

output "networking_info" {
  description = "Networking configuration info"
  value = {
    status = "configured"
  }
}
