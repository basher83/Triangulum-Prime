# ============================================================================
# LXC Containers Configuration
# ============================================================================
#
# This workspace manages lightweight LXC containers for:
# - Web servers (nginx, Apache)
# - Application servers
# - Development environments
# - Monitoring agents
# - Other lightweight services
#

locals {
  lxc_template = var.lxc_template

  tags = merge(
    var.default_tags,
    {
      workspace = "lxc-containers"
      type      = "lxc"
    }
  )
}

# Example: LXC container resource
# resource "proxmox_virtual_environment_container" "example" {
#   provider = proxmox.nexus
#
#   name        = "lxc-webserver"
#   node_name   = var.proxmox_node
#   vm_id       = 100
#   description = "Nginx web server"
#
#   initialization {
#     hostname = "webserver"
#   }
#
#   operating_system {
#     template_file_id = var.lxc_template
#     type             = "ubuntu"
#   }
#
#   cpu {
#     cores = 2
#   }
#
#   memory {
#     dedicated = 1024
#     swap      = 512
#   }
#
#   disk {
#     datastore_id = "local-lvm"
#     size         = 20
#   }
#
#   network_interface {
#     name   = "eth0"
#     bridge = "vmbr0"
#   }
#
#   started = true
#   tags    = local.tags
# }

output "lxc_template" {
  description = "LXC template used for containers"
  value       = local.lxc_template
}
