# ============================================================================
# Kubernetes Cluster Configuration
# ============================================================================
#
# This workspace manages a Kubernetes cluster using MicroK8s:
# - Control plane nodes
# - Worker nodes
# - Load balancer (optional)
# - Shared storage (optional)
#

locals {
  control_plane_count = var.control_plane_count
  worker_count        = var.worker_count
  total_nodes         = local.control_plane_count + local.worker_count

  tags = merge(
    var.default_tags,
    {
      workspace = "k8s-cluster"
      cluster   = "k8s-homelab"
    }
  )
}

# Example: Control plane nodes
# resource "proxmox_virtual_environment_vm" "k8s_control_plane" {
#   provider = proxmox.nexus
#   count    = local.control_plane_count
#
#   name      = "k8s-cp-${count.index + 1}"
#   node_name = var.proxmox_node
#   vm_id     = 300 + count.index
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
#   tags = concat(local.tags, ["control-plane"])
# }

# Example: Worker nodes
# resource "proxmox_virtual_environment_vm" "k8s_workers" {
#   provider = proxmox.nexus
#   count    = local.worker_count
#
#   name      = "k8s-worker-${count.index + 1}"
#   node_name = var.proxmox_node
#   vm_id     = 310 + count.index
#
#   cpu {
#     cores = 4
#     type  = "host"
#   }
#
#   memory {
#     dedicated = 16384
#   }
#
#   tags = concat(local.tags, ["worker"])
# }

output "cluster_info" {
  description = "Kubernetes cluster information"
  value = {
    control_plane_count = local.control_plane_count
    worker_count        = local.worker_count
    total_nodes         = local.total_nodes
  }
}
