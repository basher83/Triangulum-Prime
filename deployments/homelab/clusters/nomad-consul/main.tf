# ============================================================================
# HashiCorp Nomad + Consul Cluster Configuration
# ============================================================================
#
# This workspace manages a combined Nomad/Consul cluster:
# - Nomad servers (control plane)
# - Nomad clients (workload execution)
# - Consul servers (service mesh)
# - Consul agents (on all nodes)
#

locals {
  nomad_version  = var.nomad_version
  consul_version = var.consul_version
  server_count   = var.server_count
  client_count   = var.client_count
  total_nodes    = local.server_count + local.client_count

  tags = merge(
    var.default_tags,
    {
      workspace      = "nomad-consul-cluster"
      cluster        = "nomad-homelab"
      nomad_version  = local.nomad_version
      consul_version = local.consul_version
    }
  )
}

# Example: Server nodes (Nomad + Consul servers)
# resource "proxmox_virtual_environment_vm" "server_nodes" {
#   provider = proxmox.nexus
#   count    = local.server_count
#
#   name      = "nomad-server-${count.index + 1}"
#   node_name = var.proxmox_node
#   vm_id     = 500 + count.index
#
#   cpu {
#     cores = 4
#     type  = "host"
#   }
#
#   memory {
#     dedicated = 8192
#   }
#
#   tags = concat(local.tags, ["nomad-server", "consul-server"])
# }

# Example: Client nodes (Nomad clients + Consul agents)
# resource "proxmox_virtual_environment_vm" "client_nodes" {
#   provider = proxmox.nexus
#   count    = local.client_count
#
#   name      = "nomad-client-${count.index + 1}"
#   node_name = var.proxmox_node
#   vm_id     = 510 + count.index
#
#   cpu {
#     cores = 8
#     type  = "host"
#   }
#
#   memory {
#     dedicated = 16384
#   }
#
#   tags = concat(local.tags, ["nomad-client", "consul-agent"])
# }

output "cluster_info" {
  description = "Nomad/Consul cluster information"
  value = {
    nomad_version  = local.nomad_version
    consul_version = local.consul_version
    server_count   = local.server_count
    client_count   = local.client_count
    total_nodes    = local.total_nodes
  }
}
