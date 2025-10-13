# ============================================================================
# HashiCorp Vault Cluster Configuration
# ============================================================================
#
# This workspace manages a Vault cluster for secrets management:
# - Vault server nodes (HA cluster)
# - Integrated storage (Raft) or external backend
# - Auto-unseal configuration
# - Network and firewall rules
#

locals {
  cluster_size = var.cluster_size
  vault_version = var.vault_version

  tags = merge(
    var.default_tags,
    {
      workspace = "vault-cluster"
      cluster   = "vault-homelab"
      version   = local.vault_version
    }
  )
}

# Example: Vault server nodes
# resource "proxmox_virtual_environment_vm" "vault_nodes" {
#   provider = proxmox.nexus
#   count    = local.cluster_size
#
#   name      = "vault-${count.index + 1}"
#   node_name = var.proxmox_node
#   vm_id     = 400 + count.index
#
#   cpu {
#     cores = 2
#     type  = "host"
#   }
#
#   memory {
#     dedicated = 4096
#   }
#
#   disk {
#     interface    = "scsi0"
#     size         = 50
#     datastore_id = "local-lvm"
#   }
#
#   tags = concat(local.tags, ["vault-server"])
# }

output "vault_cluster_info" {
  description = "Vault cluster information"
  value = {
    cluster_size  = local.cluster_size
    vault_version = local.vault_version
  }
}
