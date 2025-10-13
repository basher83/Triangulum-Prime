# ============================================================================
# Single-Purpose VMs Configuration
# ============================================================================
#
# This workspace manages individual VMs for specific services:
# - DNS servers (Pi-hole, AdGuard, etc.)
# - Monitoring (Prometheus, Grafana)
# - Network services (DHCP, NTP, etc.)
# - Other standalone services
#

locals {
  vm_defaults = {
    cores   = 2
    memory  = 2048
    started = true
    on_boot = true
  }

  tags = merge(
    var.default_tags,
    {
      workspace = "single-vms"
    }
  )
}

# Example: Create VMs from count
# resource "proxmox_virtual_environment_vm" "single_vms" {
#   provider = proxmox.nexus
#   count    = var.vm_count
#
#   name      = "vm-${count.index + 1}"
#   node_name = var.proxmox_node
#   vm_id     = 200 + count.index
#
#   clone {
#     vm_id = var.vm_template_id
#     full  = true
#   }
#
#   cpu {
#     cores = local.vm_defaults.cores
#     type  = "host"
#   }
#
#   memory {
#     dedicated = local.vm_defaults.memory
#   }
#
#   network_device {
#     bridge = "vmbr0"
#   }
#
#   tags = local.tags
# }

output "vm_summary" {
  description = "Summary of single-purpose VMs"
  value = {
    template_id = var.vm_template_id
    vm_count    = var.vm_count
    node        = var.proxmox_node
  }
}
