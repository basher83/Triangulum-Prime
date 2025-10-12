# VM Module Defaults Reference

This document establishes the baseline defaults for the unified `vm` module. Use this as a reference when creating deployments to understand what needs to be overridden vs. what can rely on module defaults.

## Philosophy

**Only override defaults when you have a specific reason.** The module provides sensible defaults for most use cases. Overriding without purpose creates maintenance burden and obscures intent.

## Required Variables (No Defaults)

These **must** be specified in every deployment:

```hcl
pve_node      # Proxmox node name
vm_type       # "clone" or "image"
vm_name       # VM name
vm_disk       # Disk configuration (map)
vm_net_ifaces # Network interfaces (map)
vm_init       # Cloud-init configuration (object)
```

## Optional Variables with Defaults

### General VM Configuration

| Variable | Default | Override When... |
|----------|---------|------------------|
| `vm_id` | `null` (auto-assigned) | You need predictable VM IDs |
| `vm_description` | `null` | You want to document the VM |
| `vm_pool` | `null` | Using Proxmox resource pools |
| `vm_tags` | `[]` | You want to organize/search VMs |
| `vm_template` | `false` | Creating a template |
| `vm_user_data` | `null` | Using custom cloud-init user-data |

### VM Start Settings

```hcl
vm_start = {
  on_deploy  = true   # Override to false for templates
  on_boot    = true   # Override to false for templates
  order      = 0
  up_delay   = 0
  down_delay = 0
}
```

**Override:** Set `on_deploy` and `on_boot` to `false` for templates.

### BIOS and Machine Type

```hcl
vm_bios    = "ovmf"              # UEFI (modern, secure boot capable)
vm_machine = "q35"               # Modern chipset
vm_os      = "l26"               # Linux 2.6+ kernel
vm_scsi_hardware = "virtio-scsi-single"
```

**Recommendation:** Keep defaults unless you have legacy requirements.

### CPU Configuration

```hcl
vm_cpu = {
  type  = "host"  # Pass-through host CPU for best performance
  cores = 2       # Minimal baseline
  units = null    # CPU units (not typically needed)
}
```

**Override:** Increase `cores` for production workloads.

### Memory Configuration

```hcl
vm_mem = {
  dedicated = 2048  # 2 GB baseline
  floating  = null  # Ballooning (optional)
  shared    = null  # KSM (optional)
}
```

**Override:** Increase `dedicated` based on workload requirements.

### Display Configuration

```hcl
vm_display = {
  type   = "std"  # Standard VGA (good for templates)
  memory = 16     # 16 MB display memory
}
```

**Recommendation:** Keep defaults. Only override `type` if you need serial console or specific display adapter.

### QEMU Guest Agent

```hcl
vm_agent = {
  enabled = true     # Essential for IP retrieval
  timeout = "15m"
  trim    = true     # Enable fstrim for cloned disks
  type    = "virtio"
}
```

**Recommendation:** Keep defaults. Agent is essential for cloud-init and disk management.

### Random Number Generator (Entropy)

```hcl
vm_rng = {
  source    = "/dev/urandom"
  max_bytes = 1024
  period    = 1000
}
```

**Recommendation:** Keep defaults. Provides entropy for cryptographic operations.

### Serial Console

```hcl
vm_serial = {
  serial0 = {
    device = "socket"
  }
}
```

**Recommendation:** Keep defaults. Enables serial console access for troubleshooting.

### EFI Disk (for UEFI boot)

```hcl
vm_efi_disk = {
  datastore_id      = string  # Must specify
  file_format       = "raw"
  type              = "4m"    # 4MB EFI partition
  pre_enrolled_keys = false   # Secure boot keys
}
```

**Recommendation:** Only override if you need secure boot or different partition size.

### Disk Configuration

```hcl
vm_disk = {
  file_format = "raw"  # Best performance
  iothread    = true   # Better I/O performance
  ssd         = true   # SSD emulation (TRIM support)
  discard     = "on"   # Enable TRIM/discard
  main_disk   = false  # Only one disk should be main
}
```

**Recommendation:** Keep defaults for optimal performance and TRIM support.

### Network Interface

```hcl
vm_net_ifaces = {
  enabled    = true
  firewall   = false   # Proxmox firewall disabled by default
  model      = "virtio"
  mtu        = 1500
  vlan_id    = null    # No VLAN tagging
  rate_limit = null    # No rate limiting
  ipv4_gw    = null    # Gateway (set for primary NIC only)
}
```

**Override:** Set `firewall = true` if using Proxmox firewall, configure VLAN if needed.

### Cloud-init

```hcl
vm_init = {
  interface = "ide2"  # Proxmox recommended convention
  user      = null    # Set for VM deployments, not templates
  dns       = null    # Optional DNS configuration
}
```

**Override:** Always configure `user` for VM deployments. Leave `null` for templates when using custom `vm_user_data`.

## Common Override Patterns

### Template Creation

Override these for templates:

```hcl
vm_template = true
vm_start = {
  on_deploy = false
  on_boot   = false
}
```

### Production VM Deployment

Typically override:

```hcl
vm_cpu = {
  cores = 4  # or higher
}
vm_mem = {
  dedicated = 8192  # 8GB or higher
}
vm_disk = {
  scsi0 = {
    size = 50  # GB based on workload
  }
}
```

### Development VM

Keep most defaults, maybe adjust:

```hcl
vm_mem = {
  dedicated = 4096  # 4GB
}
```

## Anti-Patterns

**Don't do this:**

```hcl
# ❌ Repeating module defaults
vm_bios    = "ovmf"     # Module already defaults to this
vm_machine = "q35"      # Module already defaults to this
vm_display = {
  memory = 16           # Module already defaults to this
}
```

**Do this instead:**

```hcl
# ✅ Only override what you need
# Let the module handle the rest via defaults
vm_cpu = {
  cores = 4  # Actual override for this deployment
}
```

## Documentation

When overriding defaults, document **why** with inline comments:

```hcl
vm_display = {
  type = "serial0"  # Using serial console for headless troubleshooting
}

vm_agent = {
  enabled = false  # Guest agent not available in this legacy OS
}
```

## Validation

Before adding variables to a deployment:

1. Check if the module already provides the desired default
2. Ask: "Do I have a specific reason to override this?"
3. Document the override reason if not obvious
4. Consider if the override should be configurable via tfvars

## References

- Module source: `terraform/modules/vm/variables.tf`
- Examples: `terraform/deployments/examples/`
- Proxmox documentation: https://pve.proxmox.com/wiki/Qemu/KVM_Virtual_Machines
