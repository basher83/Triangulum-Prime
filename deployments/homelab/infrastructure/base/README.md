# Homelab Infrastructure Base

**Scalr Workspace:** `homelab/infra-base`
**Execution Mode:** Remote (Scalr agent: bravo-143)
**Auto Apply:** No

## Purpose

This workspace manages the foundational infrastructure for your homelab Proxmox environment:

- Network bridges and VLANs
- Storage pools and mount points
- Firewall rules and security groups
- DNS and DHCP configuration
- Shared resources and templates

## Available Proxmox Clusters

All three clusters are available in this workspace:

- **nexus** (192.168.30.30) - Use `provider = proxmox.nexus`
- **matrix** (192.168.3.5) - Use `provider = proxmox.matrix`
- **quantum** (192.168.10.2) - Use `provider = proxmox.quantum`

## Workspace Variables

Variables are configured in Scalr:

- `proxmox_node` - Primary Proxmox node (default: pve-01)
- Environment variables inherited from homelab environment

## Usage

Changes to this directory will automatically trigger a Scalr run when pushed to the `main` branch.

```bash
# Local development
tofu init
tofu plan

# After push to main, Scalr will automatically run
git add .
git commit -m "feat(infra): update base infrastructure"
git push origin main
```
