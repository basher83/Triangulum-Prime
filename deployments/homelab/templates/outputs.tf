# =============================================================================
# = Ubuntu 22.04 Template Outputs =============================================
# =============================================================================
# TEMPORARILY DISABLED FOR TESTING

# output "ubuntu_22_template_id" {
#   description = "Ubuntu 22.04 template VM ID"
#   value       = module.ubuntu_22_cloudinit.template_id
# }
# 
# output "ubuntu_22_template_name" {
#   description = "Ubuntu 22.04 template name"
#   value       = module.ubuntu_22_cloudinit.template_name
# }
# 
# output "ubuntu_22_template_node" {
#   description = "Ubuntu 22.04 template Proxmox node"
#   value       = module.ubuntu_22_cloudinit.template_node
# }
# 
# output "ubuntu_22_cloud_init_file_id" {
#   description = "Ubuntu 22.04 cloud-init file ID"
#   value       = module.ubuntu_22_cloudinit.cloud_init_file_id
# }

# =============================================================================
# = Ubuntu 24.04 Template Outputs =============================================
# =============================================================================

output "ubuntu_24_template_id" {
  description = "Ubuntu 24.04 template VM ID"
  value       = module.ubuntu_24_cloudinit.template_id
}

output "ubuntu_24_template_name" {
  description = "Ubuntu 24.04 template name"
  value       = module.ubuntu_24_cloudinit.template_name
}

output "ubuntu_24_template_node" {
  description = "Ubuntu 24.04 template Proxmox node"
  value       = module.ubuntu_24_cloudinit.template_node
}

output "ubuntu_24_cloud_init_file_id" {
  description = "Ubuntu 24.04 cloud-init file ID"
  value       = module.ubuntu_24_cloudinit.cloud_init_file_id
}

# =============================================================================
# = Summary Output ============================================================
# =============================================================================

output "templates_summary" {
  description = "Summary of deployed templates on this cluster"
  value = {
    cluster_endpoint = var.proxmox_endpoint
    cluster_node     = var.proxmox_node
    templates = {
      # ubuntu_22 = {
      #   id   = module.ubuntu_22_cloudinit.template_id
      #   name = module.ubuntu_22_cloudinit.template_name
      # }
      ubuntu_24 = {
        id   = module.ubuntu_24_cloudinit.template_id
        name = module.ubuntu_24_cloudinit.template_name
      }
    }
  }
}
