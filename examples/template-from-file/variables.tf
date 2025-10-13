# =============================================================================
# = Proxmox Connection Variables ==============================================
# =============================================================================

variable "proxmox_endpoint" {
  type        = string
  description = "Proxmox API endpoint (e.g., https://proxmox.example.com:8006)"
}

variable "proxmox_insecure" {
  type        = bool
  description = "Skip TLS verification (useful for self-signed certificates)"
  default     = true
}

variable "proxmox_node" {
  type        = string
  description = "Proxmox node name where the template will be created"
}

# =============================================================================
# = Template Configuration Variables ==========================================
# =============================================================================

variable "template_name" {
  type        = string
  description = "Name for the VM template"
  default     = "ubuntu-22-04-template"
}

variable "template_id" {
  type        = number
  description = "VM ID for the template (typically 2000-9999 range)"
  default     = 2007

  validation {
    condition     = var.template_id >= 100 && var.template_id <= 999999999
    error_message = "Template ID must be between 100 and 999999999"
  }
}

# =============================================================================
# = Cloud Image File Variables ================================================
# =============================================================================

variable "cloud_image_datastore" {
  type        = string
  description = "Proxmox datastore where the cloud image file is located"
  default     = "local"
}

variable "cloud_image_filename" {
  type        = string
  description = "Filename of the existing cloud image in the datastore"
  default     = "ubuntu-22.04-server-cloudimg-amd64.img"
}

# =============================================================================
# = Storage Variables =========================================================
# =============================================================================

variable "datastore" {
  type        = string
  description = "Proxmox datastore for VM disks"
  default     = "local-lvm"
}

# =============================================================================
# = Template Metadata =========================================================
# =============================================================================

variable "template_description" {
  type        = string
  description = "Description for the VM template"
  default     = "Ubuntu 22.04 LTS Cloud Template"
}

variable "template_tags" {
  type        = list(string)
  description = "Tags to apply to the template"
  default     = ["template", "ubuntu", "cloud-init"]
}

# =============================================================================
# = Hardware Configuration ====================================================
# =============================================================================

variable "disk_size" {
  type        = number
  description = "Disk size in GB (keep minimal for templates, expand during clone)"
  default     = 12
}

# Note: CPU, memory, BIOS, machine, OS, agent, disk format settings removed
# Templates use module defaults - customize during cloning
# See terraform/modules/vm/DEFAULTS.md for default values

# =============================================================================
# = Network Variables =========================================================
# =============================================================================

variable "network_bridge" {
  type        = string
  description = "Network bridge for the template"
  default     = "vmbr0"
}

# Note: network_firewall removed - module defaults to false

# =============================================================================
# = Cloud-init Configuration ==================================================
# =============================================================================

variable "cloud_init_datastore" {
  type        = string
  description = "Datastore for cloud-init drive"
  default     = "local"
}

variable "dns_servers" {
  type        = list(string)
  description = "DNS servers"
  default     = ["1.1.1.1", "8.8.8.8"]
}

# Note: cloud_init_interface removed - module defaults to "ide2"
