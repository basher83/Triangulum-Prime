# ============================================================================
# Multi-Cloud VPN Configuration
# ============================================================================
#
# This workspace manages VPN connections between:
# - Homelab (on-premise)
# - DigitalOcean
# - Hetzner Cloud
#

locals {
  homelab_public_ip = var.homelab_public_ip

  tags = merge(
    var.default_tags,
    {
      workspace = "multi-cloud-vpn"
      purpose   = "site-to-site-vpn"
    }
  )
}

# Example: WireGuard VPN server in DigitalOcean
# resource "digitalocean_droplet" "vpn_gateway" {
#   name   = "vpn-gateway-do"
#   region = "nyc3"
#   size   = "s-1vcpu-1gb"
#   image  = "ubuntu-22-04-x64"
#
#   tags = local.tags
#
#   user_data = templatefile("${path.module}/wireguard-setup.sh", {
#     homelab_ip = local.homelab_public_ip
#   })
# }

# Example: WireGuard VPN server in Hetzner
# resource "hcloud_server" "vpn_gateway" {
#   name        = "vpn-gateway-hetzner"
#   server_type = "cx11"
#   location    = "nbg1"
#   image       = "ubuntu-22.04"
#
#   labels = local.tags
#
#   user_data = templatefile("${path.module}/wireguard-setup.sh", {
#     homelab_ip = local.homelab_public_ip
#   })
# }

output "vpn_info" {
  description = "VPN configuration information"
  value = {
    homelab_ip = local.homelab_public_ip
  }
  sensitive = true
}
