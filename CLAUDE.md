# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Triangulum-Prime is an Infrastructure as Code (IaC) repository managing homelab and multi-cloud infrastructure using OpenTofu (Terraform) and Scalr for orchestration. The repository follows a structured approach with three-tier Scalr hierarchy (Account, Environment, Workspace) and supports multi-cluster Proxmox deployments.

## Key Technologies

-   **IaC Platform**: OpenTofu 1.8.0+ (Terraform-compatible)
-   **Orchestration**: Scalr (remote execution, state management)
-   **Providers**: Proxmox (bpg/proxmox >= 0.84.1), DigitalOcean, Hetzner
-   **Proxmox Clusters**: 3 clusters (Nexus: 192.168.30.30, Matrix: 192.168.3.5, Quantum: 192.168.10.2)

## Essential Commands

### OpenTofu/Terraform Operations

```bash
# Initialize and validate
tofu init
tofu validate
tofu fmt -recursive

# Plan and apply
tofu plan
tofu apply

# For specific deployments
cd deployments/homelab/templates
tofu init
tofu plan
tofu apply
```

### Scalr CLI Commands

```bash
# Manage Scalr configuration
cd scalr-management
tofu init
tofu plan
tofu apply

# View Scalr outputs
tofu output
tofu output -json > outputs.json
```

### Validation and Linting

```bash
# Validate all Terraform files
tofu validate

# Format code
tofu fmt -recursive

# YAML validation (if yamllint available)
yamllint scalr-management/data/
```

## Architecture Overview

### Directory Structure

```text
triangulum-prime/
├── scalr-management/          # YAML-driven Scalr account management
│   ├── data/environments/     # Environment configs (homelab.yaml, cloud.yaml)
│   └── *.tf                   # Terraform for managing Scalr itself
├── deployments/               # Scalr-managed infrastructure
│   ├── homelab/               # On-premise Proxmox infrastructure
│   │   ├── infrastructure/    # Base networking and storage
│   │   ├── vms/              # Virtual machines
│   │   ├── clusters/         # K8s, Vault, Nomad/Consul clusters
│   │   ├── lxc/              # LXC containers
│   │   └── templates/        # VM templates (Ubuntu 22.04/24.04)
│   └── cloud/                # Cloud provider resources
│       ├── digitalocean/
│       ├── hetzner/
│       └── networking/
├── terraform-bgp-vm/         # Reusable VM module
├── terraform-bgp-lxc/        # Reusable LXC module
├── modules/                  # Shared modules
│   ├── cloud/
│   ├── proxmox/
│   └── shared/
└── examples/                 # Example configurations
```

### Scalr Management Architecture

The `scalr-management/` directory uses a YAML-driven approach to manage Scalr resources:

1. **YAML Data Files**: `data/environments/*.yaml` define environments and workspaces
2. **Locals Processing**: `locals.tf` loads YAML files and transforms them into Terraform data structures
3. **Resource Creation**: Terraform resources create Scalr environments, workspaces, and provider configurations
4. **Multi-Cluster Support**: Each Proxmox cluster gets its own provider configuration (proxmox-nexus, proxmox-matrix, proxmox-quantum)

Key files:

-   `locals.tf`: YAML loading and transformation logic
-   `environments.tf`: Environment resource creation
-   `workspaces.tf`: Workspace resource creation
-   `provider-configurations.tf`: Provider credential configs

### Deployment Architecture

Each subdirectory in `deployments/` corresponds to a **Scalr workspace**:

-   **VCS Integration**: Workspaces trigger on changes to their directory
-   **Remote Execution**: OpenTofu runs on Scalr-managed agents or self-hosted agents
-   **State Management**: Remote state stored in Scalr (no local state files)
-   **Provider Configs**: Managed centrally through Scalr, injected at runtime

### Module Architecture

**terraform-bgp-vm**: Unified VM module supporting:

-   Clone from templates (`vm_type = "clone"`)
-   Create from downloaded images (`vm_type = "image"` + URL)
-   Create from existing files (`vm_type = "image"` without URL)
-   Template creation (`vm_template = true`)

**terraform-bgp-lxc**: LXC container module (less documented)

## Important Patterns and Conventions

### Scalr Workspace Configuration

Workspaces are defined in YAML with this structure:

```yaml
- name: workspace-name
  description: Description of the workspace
  auto_apply: false
  terraform_version: "1.10.0"
  execution_mode: remote
  working_directory: deployments/homelab/path
  vcs_repo:
      identifier: owner/repo
      branch: main
      trigger_patterns:
          - "deployments/homelab/path/**/*"
          - "!**/*.md" # Exclude markdown files
  provider_configs:
      - proxmox-nexus # Override default providers
  variables:
      - key: variable_name
        value: "value"
        category: terraform
        description: Variable description
```

### Multi-Cluster Provider Strategy

All homelab workspaces have access to all three Proxmox clusters through provider aliases:

```hcl
# In deployments, use provider aliases to target specific clusters
resource "proxmox_virtual_environment_vm" "example" {
  provider = proxmox.nexus   # Target Nexus cluster
  # or proxmox.matrix
  # or proxmox.quantum
}
```

Provider configurations are managed in `scalr-management/provider-configurations.tf` and referenced by name (proxmox-nexus, proxmox-matrix, proxmox-quantum) in workspace YAML files.

### Template ID Conventions

VM templates use standardized ID ranges:

-   `9000-9099`: Ubuntu templates (9000 = Ubuntu 22.04, 9001 = Ubuntu 24.04)
-   `9100-9199`: Debian templates
-   `9200-9299`: Rocky/Alma templates
-   `9300-9399`: Custom templates

### Backend Configuration

**IMPORTANT**: Do NOT add `backend` blocks to deployment code. Backends are configured at the Scalr workspace level, not in Terraform code. For local testing, use local backend or no backend.

## Workflow Patterns

### Adding a New Workspace

1. Edit appropriate YAML file in `scalr-management/data/environments/`
2. Add workspace definition with required fields
3. Apply Scalr configuration: `cd scalr-management && tofu apply`
4. Create deployment code in corresponding directory
5. Push to VCS to trigger workspace

### Local Testing Workflow

1. Navigate to deployment directory: `cd deployments/homelab/vms/single`
2. Initialize: `tofu init`
3. Plan: `tofu plan`
4. Apply: `tofu apply`
5. After testing, push to VCS to trigger Scalr workspace

### Migrating to Scalr

1. Test locally with local backend
2. Create workspace in Scalr via YAML config
3. Add Scalr backend to code (if needed)
4. Migrate state: `tofu init -migrate-state`

### Template Deployment Pattern

The `deployments/homelab/templates/` directory uses a **root orchestrator pattern**:

-   Single codebase (`main.tf`, `variables.tf`, `outputs.tf`)
-   Multiple Scalr workspaces (vm-templates-matrix, vm-templates-nexus, vm-templates-quantum)
-   Each workspace targets different cluster via `provider_configs`
-   All workspaces trigger on same directory changes

## Common Issues and Solutions

### VCS Triggers Not Working

-   Check `trigger_patterns` vs `trigger_prefixes` (mutually exclusive)
-   Verify workspace is configured correctly in Scalr UI
-   Ensure VCS provider has repository access
-   Check that changes are pushed to correct branch

### Provider Authentication Errors

-   For Proxmox: Check API token expiration (format: `username@realm!tokenid=uuid`)
-   For Cloud: Verify token permissions in provider dashboard
-   Check provider configuration in Scalr UI

### State Issues

-   Scalr handles state locking automatically
-   Check Scalr UI for running/queued runs if stuck
-   Never manually edit state files

### SSH Authentication for Proxmox

-   Local dev: Use SSH agent (`ssh_agent = true`)
-   CI/CD: Use SSH private key (`ssh_private_key = file("path")`, unencrypted, PEM format)
-   Private key must be provided via Scalr workspace variables for CI/CD

## Version Pinning

-   OpenTofu/Terraform: >= 1.0 (prefer 1.10.0)
-   Proxmox provider: >= 0.84.1
-   Always specify `terraform_version` in workspace YAML definitions
-   Use `versions.tf` files for provider version constraints

## Git Workflow

-   Main branch: `main`
-   Conventional commits preferred (based on CHANGELOG.md format)
-   Feature branches: `feature/description`
-   Scalr triggers automatically on push to configured branch

## Security Considerations

-   **Never commit secrets**: Use `.gitignore` for `terraform.tfvars`, `*.auto.tfvars`
-   **Cluster naming**: Use generic names (prod, dev, lab) not revealing hostnames in state
-   **Provider credentials**: Managed through Scalr, not in code
-   **Sensitive variables**: Mark as `sensitive: true` in YAML workspace definitions

## Module References

When referencing modules in deployments:

```hcl
# From GitHub
module "vm" {
  source = "github.com/basher83/Triangulum-Prime//terraform-bgp-vm?ref=vm/1.0.1"
  # ...
}

# From Scalr private registry
module "vm" {
  source  = "the-mothership.scalr.io/proxmox/vm/bgp"
  version = "1.0.0"
  # ...
}
```

## Testing

-   Unit tests: `tests/unit/`
-   Integration tests: `tests/integration/`
-   Terratest: `tests/terratest/`
-   No automated test commands documented; validate manually with `tofu plan`
