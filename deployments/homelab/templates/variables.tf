# =============================================================================
# = Cluster Configuration Variables ===========================================
# =============================================================================
# These variables are set by the Scalr workspace to target specific clusters

variable "proxmox_endpoint" {
  type        = string
  description = "Proxmox API endpoint (set by workspace)"
}

variable "proxmox_node" {
  type        = string
  description = "Proxmox node name (set by workspace)"
}

variable "proxmox_insecure" {
  type        = bool
  description = "Skip TLS verification"
  default     = true
}

variable "proxmox_username" {
  type        = string
  description = "Proxmox username for authentication"
}

variable "proxmox_password" {
  type        = string
  description = "Proxmox password for authentication"
}

variable "ssh_username" {
  type        = string
  description = "SSH username for Proxmox host (required for image import)"
  default     = "terraform"
}

# =============================================================================
# = Storage Configuration =====================================================
# =============================================================================

variable "datastore" {
  type        = string
  description = "Proxmox datastore for VM disks"
  default     = "local-lvm"
}

variable "cloud_image_datastore" {
  type        = string
  description = "Proxmox datastore for cloud images (must be file-based)"
  default     = "local"
}

variable "cloud_init_datastore" {
  type        = string
  description = "Proxmox datastore for cloud-init snippets"
  default     = "local"
}

# =============================================================================
# = Network Configuration =====================================================
# =============================================================================

variable "network_bridge" {
  type        = string
  description = "Network bridge for templates"
  default     = "vmbr0"
}

variable "dns_servers" {
  type        = list(string)
  description = "DNS servers for cloud-init"
  default     = ["1.1.1.1", "8.8.8.8"]
}

# =============================================================================
# = Shared Cloud-Init Configuration ===========================================
# =============================================================================

variable "user_data_file" {
  type        = string
  description = "Path to shared cloud-init user-data file"
  default     = "./shared/user-data.yaml"
}

# =============================================================================
# = Ubuntu 22.04 Template Configuration =======================================
# =============================================================================

variable "ubuntu_22_template_name" {
  type        = string
  description = "Name for Ubuntu 22.04 template"
  default     = "ubuntu22-cloudinit-template"
}

variable "ubuntu_22_template_id" {
  type        = number
  description = "VM ID for Ubuntu 22.04 template"
  default     = 9000
}

variable "ubuntu_22_template_description" {
  type        = string
  description = "Description for Ubuntu 22.04 template"
  default     = "Ubuntu 22.04 LTS Cloud Template with Custom Cloud-Init"
}

variable "ubuntu_22_template_tags" {
  type        = list(string)
  description = "Tags for Ubuntu 22.04 template"
  default     = ["template", "ubuntu", "ubuntu-22", "cloud-init"]
}

variable "ubuntu_22_cloud_image_url" {
  type        = string
  description = "Ubuntu 22.04 cloud image URL"
  default     = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
}

variable "ubuntu_22_cloud_image_filename" {
  type        = string
  description = "Filename for Ubuntu 22.04 cloud image"
  default     = "jammy-server-cloudimg-amd64.img"
}

variable "ubuntu_22_cloud_image_checksum" {
  type        = string
  description = "Checksum for Ubuntu 22.04 cloud image"
  default     = null
}

variable "ubuntu_22_user_data_snippet_name" {
  type        = string
  description = "Cloud-init snippet name for Ubuntu 22.04"
  default     = "ubuntu22-cloudinit.yaml"
}

variable "ubuntu_22_disk_size" {
  type        = number
  description = "Disk size in GB for Ubuntu 22.04 template"
  default     = 5
}

# =============================================================================
# = Ubuntu 24.04 Template Configuration =======================================
# =============================================================================

variable "ubuntu_24_template_name" {
  type        = string
  description = "Name for Ubuntu 24.04 template"
  default     = "ubuntu24-cloudinit-template"
}

variable "ubuntu_24_template_id" {
  type        = number
  description = "VM ID for Ubuntu 24.04 template"
  default     = 9001
}

variable "ubuntu_24_template_description" {
  type        = string
  description = "Description for Ubuntu 24.04 template"
  default     = "Ubuntu 24.04 LTS Cloud Template with Custom Cloud-Init"
}

variable "ubuntu_24_template_tags" {
  type        = list(string)
  description = "Tags for Ubuntu 24.04 template"
  default     = ["template", "ubuntu", "ubuntu-24", "cloud-init"]
}

variable "ubuntu_24_cloud_image_url" {
  type        = string
  description = "Ubuntu 24.04 cloud image URL"
  default     = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
}

variable "ubuntu_24_cloud_image_filename" {
  type        = string
  description = "Filename for Ubuntu 24.04 cloud image"
  default     = "noble-server-cloudimg-amd64.img"
}

variable "ubuntu_24_cloud_image_checksum" {
  type        = string
  description = "Checksum for Ubuntu 24.04 cloud image"
  default     = null
}

variable "ubuntu_24_user_data_snippet_name" {
  type        = string
  description = "Cloud-init snippet name for Ubuntu 24.04"
  default     = "ubuntu24-cloudinit.yaml"
}

variable "ubuntu_24_disk_size" {
  type        = number
  description = "Disk size in GB for Ubuntu 24.04 template"
  default     = 5
}

# =============================================================================
# = Legacy Variables (for backwards compatibility) ===========================
# =============================================================================

variable "ubuntu_version" {
  type        = string
  description = "Ubuntu version (legacy variable, not used)"
  default     = "22.04"
}

variable "debian_version" {
  type        = string
  description = "Debian version (legacy variable, not used)"
  default     = "12"
}
