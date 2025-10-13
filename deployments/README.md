# Deployments Directory

This directory contains all Scalr-managed infrastructure deployments organized by environment and purpose.

## Directory Structure

```
deployments/
├── homelab/              # On-premise Proxmox infrastructure
│   ├── infrastructure/   # Base infrastructure
│   ├── vms/             # Virtual machines
│   ├── clusters/        # Kubernetes and HashiCorp stacks
│   ├── lxc/             # LXC containers
│   └── templates/       # VM templates
│
└── cloud/               # Cloud provider resources
    ├── digitalocean/    # DigitalOcean droplets and spaces
    ├── hetzner/         # Hetzner Cloud instances and networking
    └── networking/      # Multi-cloud networking and VPN
```

## Scalr Integration

Each subdirectory corresponds to a **Scalr workspace** that:
- Automatically triggers on changes to its directory
- Uses OpenTofu as the IaC platform
- Runs on self-hosted agents (homelab) or Scalr-managed agents (cloud)
- Has environment-specific variables configured in Scalr

## Workspace Mapping

### Homelab Environment

| Directory | Scalr Workspace | Auto-Apply | Agent Pool |
|-----------|----------------|------------|------------|
| `homelab/infrastructure/base` | `homelab/infra-base` | No | bravo-143 |
| `homelab/vms/single` | `homelab/single-vms` | No* | bravo-143 |
| `homelab/clusters/k8s` | `homelab/k8s-cluster` | No | bravo-143 |
| `homelab/clusters/vault` | `homelab/vault-cluster` | No | bravo-143 |
| `homelab/clusters/nomad-consul` | `homelab/nomad-consul-cluster` | No | bravo-143 |
| `homelab/lxc` | `homelab/lxc-containers` | No* | bravo-143 |
| `homelab/templates` | `homelab/vm-templates` | No | bravo-143 |

\* Auto-apply disabled until infrastructure is production-ready. Can be re-enabled in Scalr.

### Cloud Environment

| Directory | Scalr Workspace | Auto-Apply | Agent |
|-----------|----------------|------------|-------|
| `cloud/digitalocean/droplets` | `cloud/digitalocean-droplets` | No* | Scalr |
| `cloud/digitalocean/spaces` | `cloud/digitalocean-spaces` | No | Scalr |
| `cloud/hetzner/instances` | `cloud/hetzner-instances` | No* | Scalr |
| `cloud/hetzner/networking` | `cloud/hetzner-networking` | No | Scalr |
| `cloud/networking/vpn` | `cloud/multi-cloud-vpn` | No | Scalr |

\* Auto-apply disabled until infrastructure is production-ready. Can be re-enabled in Scalr.

## Development Workflow

### Making Changes

```bash
# 1. Create a feature branch
git checkout -b feature/add-new-vm

# 2. Make changes to the appropriate deployment directory
cd deployments/homelab/vms/single
# ... edit Terraform files ...

# 3. Test locally (optional, if using local backend)
tofu init
tofu plan

# 4. Commit and push
git add .
git commit -m "feat(vms): add new monitoring VM"
git push origin feature/add-new-vm

# 5. Scalr will automatically trigger a plan for the affected workspace
# 6. Review the plan in Scalr UI
# 7. If workspace has auto-apply=yes, it will apply automatically
# 8. Otherwise, manually apply in Scalr UI
```

### VCS Triggers

Each workspace only triggers on changes to **its specific directory**:

- Changes to `homelab/vms/single/*` only trigger `homelab/single-vms`
- Changes to `cloud/digitalocean/droplets/*` only trigger `cloud/digitalocean-droplets`
- Changes to shared modules trigger all workspaces that use them

## Provider Configuration

### Homelab Workspaces

All homelab workspaces have access to **all three Proxmox clusters**:

```hcl
provider "proxmox" {
  alias = "nexus"    # 192.168.30.30
}

provider "proxmox" {
  alias = "matrix"   # 192.168.3.5
}

provider "proxmox" {
  alias = "quantum"  # 192.168.10.2
}
```

To use a specific cluster:

```hcl
resource "proxmox_virtual_environment_vm" "example" {
  provider = proxmox.nexus
  # ...
}
```

### Cloud Workspaces

Cloud workspaces use provider configurations managed by Scalr:

- **DigitalOcean**: Token and Spaces credentials
- **Hetzner**: API token

## Backend Configuration

Backends are configured at the **Scalr workspace level**, not in code:

- Local development: Use local backend or no backend
- Scalr-managed: Remote state stored in Scalr
- No `backend` block needed in `.tf` files

## Environment Variables

Environment-level variables (inherited by all workspaces):

- Homelab: `TF_VAR_default_tags`, `TF_VAR_datacenter`
- Cloud: (none currently, add as needed)

Workspace-specific variables are configured in:
- **Scalr UI**: For sensitive values
- **YAML files**: `scalr-management/data/environments/*.yaml`

## Best Practices

1. **One workspace = One purpose**: Keep workspaces focused
2. **Use README files**: Document each workspace's purpose
3. **Version pinning**: Pin provider versions for stability
4. **Auto-apply carefully**: Only enable for low-risk workspaces
5. **Test locally first**: Validate changes before pushing
6. **Descriptive commits**: Use conventional commit messages
7. **Review plans**: Always review Scalr plans before applying

## Troubleshooting

### Workspace not triggering

Check:
- Is the VCS repo correctly connected in Scalr?
- Are trigger prefixes/patterns configured correctly?
- Did you push to the correct branch (usually `main`)?

### Provider authentication errors

- Homelab: Check Proxmox API token expiration
- Cloud: Verify token permissions in provider dashboard

### State locking issues

- Scalr handles state locking automatically
- If stuck, check Scalr UI for running/queued runs

## Related Documentation

- [Scalr Management](../scalr-management/README.md) - How to manage Scalr with Terraform
- [Modules](../modules/README.md) - Reusable Terraform modules
- [Examples](../examples/README.md) - Example configurations
