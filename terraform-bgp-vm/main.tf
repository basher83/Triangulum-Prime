# =============================================================================
# = VM Creation ===============================================================
# =============================================================================

locals {
  src_file_disk = anytrue([for k, v in var.vm_disk : v.main_disk]) ? [for k, v in var.vm_disk : k if v.main_disk] : [for k, v in var.vm_disk : k if k == keys(var.vm_disk)[0]]
}

# =============================================================================
# = Image Download (Optional) =================================================
# =============================================================================
# Downloads cloud image if URL is provided in src_file.url
# This enables automated image management via Terraform instead of manual downloads

resource "proxmox_virtual_environment_download_file" "vm_image" {
  count = var.vm_type == "image" && var.src_file != null && var.src_file.url != null ? 1 : 0

  content_type       = "iso"
  datastore_id       = var.src_file.datastore_id
  node_name          = var.pve_node
  url                = var.src_file.url
  file_name          = var.src_file.file_name
  checksum           = var.src_file.checksum
  checksum_algorithm = var.src_file.checksum != null ? var.src_file.checksum_algorithm : null
}

resource "proxmox_virtual_environment_vm" "pve_vm" {
  # Proxmox
  node_name = var.pve_node

  # VM Information
  name        = var.vm_name
  description = var.vm_description
  tags        = var.vm_tags
  vm_id       = var.vm_id
  pool_id     = var.vm_pool
  template    = var.vm_template

  # Boot settings (templates cannot be started)
  started = var.vm_template ? false : var.vm_start.on_deploy
  on_boot = var.vm_template ? false : var.vm_start.on_boot

  startup {
    order      = var.vm_start.order
    up_delay   = var.vm_start.up_delay
    down_delay = var.vm_start.down_delay
  }

  dynamic "clone" {
    for_each = (var.vm_type == "clone") ? ["enabled"] : []
    content {
      datastore_id = var.src_clone.datastore_id
      node_name    = (var.src_clone.node_name != null) ? var.src_clone.node_name : var.pve_node
      vm_id        = var.src_clone.tpl_id
      full         = true
    }
  }

  # VM Configuration
  operating_system {
    type = var.vm_os
  }

  bios          = (var.vm_type == "image") ? var.vm_bios : null
  machine       = (var.vm_type == "image") ? var.vm_machine : null
  scsi_hardware = (var.vm_type == "image") ? var.vm_scsi_hardware : null
  tablet_device = false # Disable tablet device for better compatibility

  cpu {
    type  = var.vm_cpu.type
    cores = var.vm_cpu.cores
    units = var.vm_cpu.units
  }

  memory {
    dedicated = var.vm_mem.dedicated
    floating  = (var.vm_mem.floating != null) ? var.vm_mem.floating : var.vm_mem.dedicated
    shared    = var.vm_mem.shared
  }

  vga {
    type   = var.vm_display.type
    memory = var.vm_display.memory
  }

  agent {
    enabled = var.vm_agent.enabled
    timeout = var.vm_agent.timeout
    trim    = var.vm_agent.trim
    type    = var.vm_agent.type
  }

  # Random Number Generator for entropy
  dynamic "rng" {
    for_each = var.vm_rng != null ? [var.vm_rng] : []
    content {
      source    = rng.value.source
      max_bytes = rng.value.max_bytes
      period    = rng.value.period
    }
  }

  dynamic "serial_device" {
    for_each = var.vm_serial != null ? var.vm_serial : {}
    content {
      device = serial_device.value.device
    }
  }

  dynamic "hostpci" {
    for_each = var.vm_pcie != null ? var.vm_pcie : {}
    content {
      device  = hostpci.key
      mapping = hostpci.value.name
      pcie    = hostpci.value.pcie
      xvga    = hostpci.value.primary_gpu
    }
  }

  dynamic "efi_disk" {
    for_each = (var.vm_bios == "ovmf") ? ["enabled"] : []
    content {
      datastore_id      = var.vm_efi_disk.datastore_id
      file_format       = var.vm_efi_disk.file_format
      type              = var.vm_efi_disk.type
      pre_enrolled_keys = var.vm_efi_disk.pre_enrolled_keys
    }
  }

  # If the creation type is 'image', the fist disk will be used as base for the VM img file.
  # Supports both downloaded images (when URL provided) and existing files
  dynamic "disk" {
    for_each = (var.vm_type == "image") ? { for k, v in var.vm_disk : k => v if contains(local.src_file_disk, k) } : {}
    content {
      interface    = disk.key
      datastore_id = disk.value.datastore_id
      file_format  = disk.value.file_format
      # Use downloaded image if URL was provided, otherwise reference existing file
      file_id  = var.src_file.url != null ? proxmox_virtual_environment_download_file.vm_image[0].id : "${var.src_file.datastore_id}:iso/${var.src_file.file_name}"
      size     = disk.value.size
      iothread = disk.value.iothread
      ssd      = disk.value.ssd
      discard  = disk.value.discard
    }
  }

  dynamic "disk" {
    for_each = (var.vm_type == "clone") ? var.vm_disk : { for k, v in var.vm_disk : k => v if !contains(local.src_file_disk, k) }
    content {
      interface    = disk.key
      datastore_id = disk.value.datastore_id
      file_format  = disk.value.file_format
      size         = disk.value.size
      iothread     = disk.value.iothread
      ssd          = disk.value.ssd
      discard      = disk.value.discard
    }
  }

  dynamic "network_device" {
    for_each = var.vm_net_ifaces
    content {
      bridge       = network_device.value.bridge
      disconnected = !network_device.value.enabled
      firewall     = network_device.value.firewall
      mac_address  = network_device.value.mac_addr
      model        = network_device.value.model
      mtu          = network_device.value.mtu
      rate_limit   = network_device.value.rate_limit
      vlan_id      = network_device.value.vlan_id
    }
  }

  initialization {
    datastore_id = var.vm_init.datastore_id
    interface    = var.vm_init.interface

    dynamic "ip_config" {
      for_each = var.vm_net_ifaces
      content {
        ipv4 {
          address = ip_config.value.ipv4_addr
          gateway = ip_config.value.ipv4_gw != null ? ip_config.value.ipv4_gw : null
        }
      }
    }

    dynamic "dns" {
      for_each = (var.vm_init.dns != null) ? ["enabled"] : []
      content {
        domain  = var.vm_init.dns.domain
        servers = var.vm_init.dns.servers
      }
    }

    dynamic "user_account" {
      for_each = (var.vm_init.user != null && var.vm_user_data == null) ? ["enabled"] : []
      content {
        username = var.vm_init.user.name
        password = var.vm_init.user.password
        keys     = var.vm_init.user.keys
      }
    }

    user_data_file_id = (var.vm_init.user == null && var.vm_user_data != null) ? var.vm_user_data : null

  }

  lifecycle {
    # Ignore changes to cloud-init user accounts to prevent forced replacement
    # SSH key changes in cloud-init trigger replacement which is often undesirable
    # Note: lifecycle arguments (prevent_destroy, create_before_destroy, ignore_changes)
    # cannot use variables - they must be static. Set these in deployment configs as needed.
    ignore_changes = [
      initialization[0].user_account,
    ]

    precondition {
      condition     = var.vm_type == "clone" ? var.src_clone != null : true
      error_message = "Variable 'src_clone' is required when using the VM creation type is 'clone'"
    }

    precondition {
      condition     = var.vm_type == "image" ? var.src_file != null : true
      error_message = "Variable 'src_file' is required when using the VM creation type is 'image'"
    }

    precondition {
      condition     = var.vm_bios == "ovmf" ? var.vm_efi_disk != null : true
      error_message = "Variable 'vm_efi_disk' is required when using the VM bios type is 'ovmf'"
    }

    precondition {
      condition     = ((var.vm_init.user != null && var.vm_user_data == null) || (var.vm_init.user == null && var.vm_user_data != null) || (var.vm_init.user == null && var.vm_user_data == null))
      error_message = "Variables 'vm_init.user' and 'vm_user_data' are incompatible, only one should be set."
    }
  }
}
