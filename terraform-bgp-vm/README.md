# VM Module

Unified Terraform module for creating Proxmox VMs with support for cloning from templates, direct image imports, and template creation.

## Features

- **Flexible VM Creation**: Clone from templates or create from cloud images
- **Template Support**: Create reusable VM templates for fast cloning
- **Automated Image Download**: Optional cloud image download via URL
- **Template + Clone Workflow**: Single module for both template creation and VM deployment
- **Advanced Hardware**: QEMU Guest Agent, RNG device, serial console support
- **Cloud-init Integration**: Built-in cloud-init support for automated VM configuration
- **Dual Network Support**: Multiple network interfaces with VLAN tagging

## Referancing in deployments

- **From Github:**

```hcl
module "single_vm" {
  source = "github.com/basher83/Triangulum-Prime//terraform-bgp-vm?ref=v1.0.0"

	# Set 6 required variables below.

	# PVE Node name on which the VM will be created on.
 	pve_node = <value>

	# VM Disks configuration. Use the 'main_disk' value to tag a disk as main to host the VM image. Only usefull with creation type 'image'.
 	vm_disk = <value>

	# Initial configuration for the VM. Required for the creation of the Cloud-Init drive. Uses ide2 by default (Proxmox recommended convention).
 	vm_init = <value>

	# The name of the VM.
 	vm_name = <value>

	# VM network interfaces configuration. Terraform provider bpg/proxmox cannot work properly without network access.
 	vm_net_ifaces = <value>

	# The source type used for the creation of the vm. Can either be 'clone' or 'image'.
 	vm_type = <value>
  }
```

- **From Scalr:**

```hcl
module "vm" {
	source  = "the-mothership.scalr.io/proxmox/vm/bgp"
	version = "1.0.0"

	# Set 6 required variables below.

	# PVE Node name on which the VM will be created on.
 	pve_node = <value>

	# VM Disks configuration. Use the 'main_disk' value to tag a disk as main to host the VM image. Only usefull with creation type 'image'.
 	vm_disk = <value>

	# Initial configuration for the VM. Required for the creation of the Cloud-Init drive. Uses ide2 by default (Proxmox recommended convention).
 	vm_init = <value>

	# The name of the VM.
 	vm_name = <value>

	# VM network interfaces configuration. Terraform provider bpg/proxmox cannot work properly without network access.
 	vm_net_ifaces = <value>

	# The source type used for the creation of the vm. Can either be 'clone' or 'image'.
 	vm_type = <value>
}
```

## Module Types

### 1. Clone from Template (`vm_type = "clone"`)

Clone VMs from existing templates for fast deployment.

```hcl
module "my_vm" {
  source = "path/to/modules/vm"

  vm_type  = "clone"
  pve_node = "proxmox-node"

  src_clone = {
    datastore_id = "local-lvm"
    tpl_id       = 2006
  }

  vm_name = "my-vm"
  # ... additional configuration
}
```

### 2. Create from Downloaded Image (`vm_type = "image"` + URL)

Automatically download cloud image and create VM/template.

```hcl
module "ubuntu_template" {
  source = "path/to/modules/vm"

  vm_type     = "image"
  vm_template = true  # Mark as template
  pve_node    = "proxmox-node"

  src_file = {
    url          = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
    datastore_id = "local"
    file_name    = "ubuntu-22.04.img"
    checksum     = "sha256:abc123..."  # Optional
  }

  vm_name = "ubuntu-22-04-template"
  # ... additional configuration
}
```

### 3. Create from Existing File (`vm_type = "image"` without URL)

Use pre-existing cloud image file on Proxmox storage.

```hcl
module "ubuntu_template" {
  source = "path/to/modules/vm"

  vm_type     = "image"
  vm_template = true
  pve_node    = "proxmox-node"

  src_file = {
    datastore_id = "local"
    file_name    = "ubuntu-22.04.img"
    # No URL - file must already exist
  }

  vm_name = "ubuntu-22-04-template"
  # ... additional configuration
}
```

## Template Creation Workflow

This module supports creating templates that can be used for cloning:

```hcl
# Step 1: Create template with automated download
module "ubuntu_template" {
  source      = "path/to/modules/vm"
  vm_type     = "image"
  vm_template = true

  src_file = {
    url          = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
    datastore_id = "local"
    file_name    = "ubuntu-22.04.img"
  }

  vm_name = "ubuntu-template"
  vm_id   = 2006
  # ... template configuration
}

# Step 2: Clone VMs from template
module "production_vm" {
  source   = "path/to/modules/vm"
  vm_type  = "clone"

  src_clone = {
    datastore_id = "local-lvm"
    tpl_id       = module.ubuntu_template.vm_id
  }

  vm_name = "prod-web-01"
  # ... VM-specific configuration
}
```

## Examples

See the [examples](../examples/) directory for complete examples:

- **[template-from-url](../examples/template-from-url/)** - Create template with automated image download
- **[template-from-file](../examples/template-from-file/)** - Create template from existing image file
- **[single-vm](../examples/single-vm/)** - Deploy single VM by cloning template
- **[microk8s-cluster](../examples/microk8s-cluster/)** - Deploy multi-VM cluster via vm-cluster module

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                                     | Version   |
| ------------------------------------------------------------------------ | --------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.0    |
| <a name="requirement_proxmox"></a> [proxmox](#requirement_proxmox)       | >= 0.84.1 |

## Providers

| Name                                                         | Version |
| ------------------------------------------------------------ | ------- |
| <a name="provider_proxmox"></a> [proxmox](#provider_proxmox) | 0.84.1  |

## Modules

No modules.

## Resources

| Name                                                                                                                                                              | Type     |
| ----------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- |
| [proxmox_virtual_environment_download_file.vm_image](https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_download_file) | resource |
| [proxmox_virtual_environment_vm.pve_vm](https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_vm)                         | resource |

## Inputs

| Name                                                                              | Description                                                                                                                                                            | Type                                                                                                                                                                                                                                                                                                                                                                  | Default                                                                                                                    | Required |
| --------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------- | :------: |
| <a name="input_pve_node"></a> [pve_node](#input_pve_node)                         | PVE Node name on which the VM will be created on.                                                                                                                      | `string`                                                                                                                                                                                                                                                                                                                                                              | n/a                                                                                                                        |   yes    |
| <a name="input_src_clone"></a> [src_clone](#input_src_clone)                      | The target to clone as base for the VM. Cannot be used with 'src_file'                                                                                                 | <pre>object({<br/> datastore_id = string<br/> node_name = optional(string)<br/> tpl_id = number<br/> })</pre>                                                                                                                                                                                                                                                         | `null`                                                                                                                     |    no    |
| <a name="input_src_file"></a> [src_file](#input_src_file)                         | The target ISO/image file to use as base for the VM. If 'url' is provided, the image will be downloaded. Cannot be used with 'src_clone'                               | <pre>object({<br/> datastore_id = string<br/> file_name = string<br/> url = optional(string)<br/> checksum = optional(string)<br/> checksum_algorithm = optional(string, "sha256")<br/> file_format = optional(string, "img")<br/> })</pre>                                                                                                                           | `null`                                                                                                                     |    no    |
| <a name="input_vm_agent"></a> [vm_agent](#input_vm_agent)                         | The QEMU guest agent configuration. Enables communication with the VM for IP address retrieval and graceful shutdown. TRIM enabled by default for fstrim_cloned_disks. | <pre>object({<br/> enabled = optional(bool, true)<br/> timeout = optional(string, "15m")<br/> trim = optional(bool, true)<br/> type = optional(string, "virtio")<br/> })</pre>                                                                                                                                                                                        | `{}`                                                                                                                       |    no    |
| <a name="input_vm_bios"></a> [vm_bios](#input_vm_bios)                            | The BIOS Implementation of the VM. Can either be 'seabios' or 'ovmf'.                                                                                                  | `string`                                                                                                                                                                                                                                                                                                                                                              | `"ovmf"`                                                                                                                   |    no    |
| <a name="input_vm_cpu"></a> [vm_cpu](#input_vm_cpu)                               | The CPU Configuration of the VM.                                                                                                                                       | <pre>object({<br/> type = optional(string, "host")<br/> cores = optional(number, 2)<br/> units = optional(number)<br/> })</pre>                                                                                                                                                                                                                                       | `{}`                                                                                                                       |    no    |
| <a name="input_vm_description"></a> [vm_description](#input_vm_description)       | The description of the VM.                                                                                                                                             | `string`                                                                                                                                                                                                                                                                                                                                                              | `null`                                                                                                                     |    no    |
| <a name="input_vm_disk"></a> [vm_disk](#input_vm_disk)                            | VM Disks configuration. Use the 'main_disk' value to tag a disk as main to host the VM image. Only usefull with creation type 'image'.                                 | <pre>map(object({<br/> datastore_id = string<br/> size = number<br/> file_format = optional(string, "raw")<br/> iothread = optional(bool, true)<br/> ssd = optional(bool, true)<br/> discard = optional(string, "on")<br/> main_disk = optional(bool, false)<br/> }))</pre>                                                                                           | n/a                                                                                                                        |   yes    |
| <a name="input_vm_display"></a> [vm_display](#input_vm_display)                   | The Display Configuration of the VM.                                                                                                                                   | <pre>object({<br/> type = optional(string, "std")<br/> memory = optional(number, 16)<br/> })</pre>                                                                                                                                                                                                                                                                    | `{}`                                                                                                                       |    no    |
| <a name="input_vm_efi_disk"></a> [vm_efi_disk](#input_vm_efi_disk)                | The UEFI disk device.                                                                                                                                                  | <pre>object({<br/> datastore_id = string<br/> file_format = optional(string, "raw")<br/> type = optional(string, "4m")<br/> pre_enrolled_keys = optional(bool, false)<br/> })</pre>                                                                                                                                                                                   | `null`                                                                                                                     |    no    |
| <a name="input_vm_id"></a> [vm_id](#input_vm_id)                                  | The ID of the VM.                                                                                                                                                      | `number`                                                                                                                                                                                                                                                                                                                                                              | `null`                                                                                                                     |    no    |
| <a name="input_vm_init"></a> [vm_init](#input_vm_init)                            | Initial configuration for the VM. Required for the creation of the Cloud-Init drive. Uses ide2 by default (Proxmox recommended convention).                            | <pre>object({<br/> datastore_id = string<br/> interface = optional(string, "ide2")<br/> user = optional(object({<br/> name = optional(string)<br/> password = optional(string)<br/> keys = optional(list(string))<br/> }))<br/> dns = optional(object({<br/> domain = optional(string)<br/> servers = optional(list(string))<br/> }))<br/> })</pre>                   | n/a                                                                                                                        |   yes    |
| <a name="input_vm_machine"></a> [vm_machine](#input_vm_machine)                   | The machine type of the VM.                                                                                                                                            | `string`                                                                                                                                                                                                                                                                                                                                                              | `"q35"`                                                                                                                    |    no    |
| <a name="input_vm_mem"></a> [vm_mem](#input_vm_mem)                               | The Memory Configuration of the VM.                                                                                                                                    | <pre>object({<br/> dedicated = optional(number, 2048)<br/> floating = optional(number)<br/> shared = optional(number)<br/> })</pre>                                                                                                                                                                                                                                   | `{}`                                                                                                                       |    no    |
| <a name="input_vm_name"></a> [vm_name](#input_vm_name)                            | The name of the VM.                                                                                                                                                    | `string`                                                                                                                                                                                                                                                                                                                                                              | n/a                                                                                                                        |   yes    |
| <a name="input_vm_net_ifaces"></a> [vm_net_ifaces](#input_vm_net_ifaces)          | VM network interfaces configuration. Terraform provider bpg/proxmox cannot work properly without network access.                                                       | <pre>map(object({<br/> bridge = string<br/> enabled = optional(bool, true)<br/> firewall = optional(bool, false)<br/> mac_addr = optional(string)<br/> model = optional(string, "virtio")<br/> mtu = optional(number, 1500)<br/> rate_limit = optional(string)<br/> vlan_id = optional(number)<br/> ipv4_addr = string<br/> ipv4_gw = optional(string)<br/> }))</pre> | n/a                                                                                                                        |   yes    |
| <a name="input_vm_os"></a> [vm_os](#input_vm_os)                                  | The Operating System configuration of the VM.                                                                                                                          | `string`                                                                                                                                                                                                                                                                                                                                                              | `"l26"`                                                                                                                    |    no    |
| <a name="input_vm_pcie"></a> [vm_pcie](#input_vm_pcie)                            | VM host PCI device mapping.                                                                                                                                            | <pre>map(object({<br/> name = string<br/> pcie = optional(bool, true)<br/> primary_gpu = optional(bool, false)<br/> }))</pre>                                                                                                                                                                                                                                         | `null`                                                                                                                     |    no    |
| <a name="input_vm_pool"></a> [vm_pool](#input_vm_pool)                            | The Pool in which to place the VM.                                                                                                                                     | `string`                                                                                                                                                                                                                                                                                                                                                              | `null`                                                                                                                     |    no    |
| <a name="input_vm_rng"></a> [vm_rng](#input_vm_rng)                               | Random number generator device configuration. Provides entropy to the VM for cryptographic operations.                                                                 | <pre>object({<br/> source = optional(string, "/dev/urandom")<br/> max_bytes = optional(number, 1024)<br/> period = optional(number, 1000)<br/> })</pre>                                                                                                                                                                                                               | <pre>{<br/> "source": "/dev/urandom"<br/>}</pre>                                                                           |    no    |
| <a name="input_vm_scsi_hardware"></a> [vm_scsi_hardware](#input_vm_scsi_hardware) | The SCSI hardware type of the VM.                                                                                                                                      | `string`                                                                                                                                                                                                                                                                                                                                                              | `"virtio-scsi-single"`                                                                                                     |    no    |
| <a name="input_vm_serial"></a> [vm_serial](#input_vm_serial)                      | Serial device configuration. Enables serial console access.                                                                                                            | <pre>map(object({<br/> device = optional(string, "socket")<br/> }))</pre>                                                                                                                                                                                                                                                                                             | <pre>{<br/> "serial0": {<br/> "device": "socket"<br/> }<br/>}</pre>                                                        |    no    |
| <a name="input_vm_start"></a> [vm_start](#input_vm_start)                         | The start settings for the VM.                                                                                                                                         | <pre>object({<br/> on_deploy = bool<br/> on_boot = bool<br/> order = optional(number, 0)<br/> up_delay = optional(number, 0)<br/> down_delay = optional(number, 0)<br/> })</pre>                                                                                                                                                                                      | <pre>{<br/> "down_delay": 0,<br/> "on_boot": true,<br/> "on_deploy": true,<br/> "order": 0,<br/> "up_delay": 0<br/>}</pre> |    no    |
| <a name="input_vm_tags"></a> [vm_tags](#input_vm_tags)                            | A list of tags associated to the VM.                                                                                                                                   | `list(string)`                                                                                                                                                                                                                                                                                                                                                        | `[]`                                                                                                                       |    no    |
| <a name="input_vm_template"></a> [vm_template](#input_vm_template)                | Convert the VM into a template. Templates cannot be started and are used as base for cloning VMs.                                                                      | `bool`                                                                                                                                                                                                                                                                                                                                                                | `false`                                                                                                                    |    no    |
| <a name="input_vm_type"></a> [vm_type](#input_vm_type)                            | The source type used for the creation of the vm. Can either be 'clone' or 'image'.                                                                                     | `string`                                                                                                                                                                                                                                                                                                                                                              | n/a                                                                                                                        |   yes    |
| <a name="input_vm_user_data"></a> [vm_user_data](#input_vm_user_data)             | cloud-init configuration for the VM's users                                                                                                                            | `string`                                                                                                                                                                                                                                                                                                                                                              | `null`                                                                                                                     |    no    |

## Outputs

| Name                                                                          | Description                                                 |
| ----------------------------------------------------------------------------- | ----------------------------------------------------------- |
| <a name="output_ipv4_addresses"></a> [ipv4_addresses](#output_ipv4_addresses) | List of IPv4 addresses assigned to the VM                   |
| <a name="output_ipv6_addresses"></a> [ipv6_addresses](#output_ipv6_addresses) | List of IPv6 addresses assigned to the VM                   |
| <a name="output_mac_addresses"></a> [mac_addresses](#output_mac_addresses)    | List of MAC addresses assigned to the VM network interfaces |
| <a name="output_vm_id"></a> [vm_id](#output_vm_id)                            | The ID of the created VM                                    |
| <a name="output_vm_name"></a> [vm_name](#output_vm_name)                      | The name of the created VM                                  |
| <a name="output_vm_node"></a> [vm_node](#output_vm_node)                      | The Proxmox node where the VM is deployed                   |
| <a name="output_vm_resource"></a> [vm_resource](#output_vm_resource)          | Full VM resource object for advanced use cases              |

<!-- END_TF_DOCS -->
