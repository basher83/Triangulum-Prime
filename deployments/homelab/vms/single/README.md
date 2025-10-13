# Homelab Single-Purpose VMs

**Scalr Workspace:** `homelab/single-vms`
**Execution Mode:** Remote (Scalr agent: bravo-143)
**Auto Apply:** No (disabled until production-ready)

## Purpose

This workspace manages single-purpose virtual machines for various services:

- DNS servers (Pi-hole, AdGuard, Unbound)
- Monitoring stack (Prometheus, Grafana, Loki)
- Network services (NTP, DHCP, TFTP)
- Jump/bastion hosts
- Other standalone services

## Available Proxmox Clusters

- **nexus** (192.168.30.30)
- **matrix** (192.168.3.5)
- **quantum** (192.168.10.2)

## Workspace Variables

Configured in Scalr (scalr-management/data/environments/homelab.yaml):

- `vm_template_id` = "2006" (Ubuntu 22.04 template)
- `vm_count` = "3"

## Deployment

Changes pushed to the `main` branch will trigger a Scalr plan. Review the plan in the Scalr UI and manually apply when ready. Auto-apply is disabled for safety until your infrastructure is production-ready.
