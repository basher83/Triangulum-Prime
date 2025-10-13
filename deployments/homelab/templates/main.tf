# =============================================================================
# = VM Templates Orchestrator =================================================
# =============================================================================
# This orchestrator deploys all VM templates to the target Proxmox cluster.
# The cluster is determined by workspace variables:
# - proxmox_node: Target Proxmox node
# - proxmox_endpoint: Target Proxmox API endpoint
#
# Each workspace (matrix, nexus, quantum) uses this same code but with
# different variables and provider configurations.

# =============================================================================
# = Ubuntu 22.04 Template =====================================================
# =============================================================================

module "ubuntu_22_cloudinit" {
  source = "./ubuntu-22-cloudinit"

  # Cluster-specific configuration (from workspace variables)
  proxmox_endpoint = var.proxmox_endpoint
  proxmox_node     = var.proxmox_node
  proxmox_insecure = var.proxmox_insecure
  ssh_username     = var.ssh_username

  # Template configuration
  template_name        = var.ubuntu_22_template_name
  template_id          = var.ubuntu_22_template_id
  template_description = var.ubuntu_22_template_description
  template_tags        = var.ubuntu_22_template_tags

  # Cloud image configuration
  cloud_image_url      = var.ubuntu_22_cloud_image_url
  cloud_image_filename = var.ubuntu_22_cloud_image_filename
  cloud_image_checksum = var.ubuntu_22_cloud_image_checksum

  # Storage configuration
  datastore              = var.datastore
  cloud_image_datastore  = var.cloud_image_datastore
  cloud_init_datastore   = var.cloud_init_datastore

  # Shared cloud-init configuration
  user_data_file         = var.user_data_file
  user_data_snippet_name = var.ubuntu_22_user_data_snippet_name
  dns_servers            = var.dns_servers

  # Network configuration
  network_bridge = var.network_bridge

  # Disk configuration
  disk_size = var.ubuntu_22_disk_size
}

# =============================================================================
# = Ubuntu 24.04 Template =====================================================
# =============================================================================

module "ubuntu_24_cloudinit" {
  source = "./ubuntu-24-cloudinit"

  # Cluster-specific configuration (from workspace variables)
  proxmox_endpoint = var.proxmox_endpoint
  proxmox_node     = var.proxmox_node
  proxmox_insecure = var.proxmox_insecure
  ssh_username     = var.ssh_username

  # Template configuration
  template_name        = var.ubuntu_24_template_name
  template_id          = var.ubuntu_24_template_id
  template_description = var.ubuntu_24_template_description
  template_tags        = var.ubuntu_24_template_tags

  # Cloud image configuration
  cloud_image_url      = var.ubuntu_24_cloud_image_url
  cloud_image_filename = var.ubuntu_24_cloud_image_filename
  cloud_image_checksum = var.ubuntu_24_cloud_image_checksum

  # Storage configuration
  datastore              = var.datastore
  cloud_image_datastore  = var.cloud_image_datastore
  cloud_init_datastore   = var.cloud_init_datastore

  # Shared cloud-init configuration
  user_data_file         = var.user_data_file
  user_data_snippet_name = var.ubuntu_24_user_data_snippet_name
  dns_servers            = var.dns_servers

  # Network configuration
  network_bridge = var.network_bridge

  # Disk configuration
  disk_size = var.ubuntu_24_disk_size
}
