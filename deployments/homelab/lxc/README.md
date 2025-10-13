# Homelab LXC Containers

**Scalr Workspace:** `homelab/lxc-containers`
**Execution Mode:** Remote (Scalr agent: bravo-143)
**Auto Apply:** No (disabled until production-ready)

## Purpose

This workspace manages Proxmox LXC containers for lightweight services:

- Web servers (nginx, Apache, Caddy)
- Application servers (Node.js, Python)
- Development environments
- Monitoring agents (Telegraf, node_exporter)
- Build agents
- Testing environments

## LXC vs VMs

LXC containers are ideal when you need:

- **Faster startup times** (seconds vs minutes)
- **Lower resource overhead** (shared kernel)
- **Higher density** (more containers per host)
- **Efficient resource usage**

Use VMs when you need:

- Different OS kernels
- Full isolation
- Running Windows or non-Linux OS
- Nested virtualization

## Workspace Variables

Configured in Scalr:

- `lxc_template` = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"

## Deployment

Changes pushed to the `main` branch will trigger a Scalr plan. Review the plan in the Scalr UI and manually apply when ready. Auto-apply is disabled for safety until your infrastructure is production-ready.

## Common Use Cases

```hcl
# Web server
resource "proxmox_virtual_environment_container" "webserver" {
  name = "nginx-01"
  # ... configuration
}

# Database
resource "proxmox_virtual_environment_container" "database" {
  name = "postgres-01"
  # ... configuration
}

# Development environment
resource "proxmox_virtual_environment_container" "dev" {
  name = "dev-sandbox"
  # ... configuration
}
```

## Performance Tips

- Use privileged containers for better performance (with security consideration)
- Enable nesting if you need Docker-in-LXC
- Use local storage for better I/O performance
- Limit swap usage for critical containers
