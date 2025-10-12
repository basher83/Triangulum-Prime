# =============================================================================
# ===== Outputs ===============================================================
# =============================================================================

# =============================================================================
# Enhanced IP Output with Fallback Logic
# See: docs/terraform/deployment-patterns.md#pattern-3-enhanced-ip-output-with-fallbacks
# =============================================================================

locals {
  # Extract configured IP from first network interface
  configured_primary_ip = try(
    split("/", values(var.vm_net_ifaces)[0].ipv4_addr)[0],
    null
  )

  # Get detected IPs from QEMU guest agent
  raw_detected_ips = try(
    flatten(proxmox_virtual_environment_vm.pve_vm.ipv4_addresses),
    []
  )

  # Filter out localhost and empty addresses
  valid_detected_ips = [
    for ip in local.raw_detected_ips : ip
    if ip != "" && ip != "127.0.0.1" && ip != null
  ]

  # Get primary IP from guest agent (first non-localhost IP)
  detected_primary_ip = length(local.valid_detected_ips) > 0 ? local.valid_detected_ips[0] : null
}

output "vm_id" {
  description = "The ID of the created VM"
  value       = proxmox_virtual_environment_vm.pve_vm.id
}

output "vm_name" {
  description = "The name of the created VM"
  value       = proxmox_virtual_environment_vm.pve_vm.name
}

output "vm_node" {
  description = "The Proxmox node where the VM is deployed"
  value       = proxmox_virtual_environment_vm.pve_vm.node_name
}

output "ipv4_addresses" {
  description = "List of IPv4 addresses assigned to the VM (from QEMU guest agent)"
  value       = proxmox_virtual_environment_vm.pve_vm.ipv4_addresses
}

output "ipv6_addresses" {
  description = "List of IPv6 addresses assigned to the VM (from QEMU guest agent)"
  value       = proxmox_virtual_environment_vm.pve_vm.ipv6_addresses
}

output "mac_addresses" {
  description = "List of MAC addresses assigned to the VM network interfaces"
  value       = proxmox_virtual_environment_vm.pve_vm.mac_addresses
}

output "primary_ip" {
  description = "Primary IPv4 address (detected via guest agent, falls back to configured IP)"
  value       = coalesce(local.detected_primary_ip, local.configured_primary_ip, "N/A")
}

output "vm_resource" {
  description = "Full VM resource object for advanced use cases"
  value       = proxmox_virtual_environment_vm.pve_vm
  sensitive   = true
}
