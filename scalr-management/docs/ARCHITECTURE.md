# Scalr Management Architecture

This document describes the architecture and organization of variables, provider configurations, and authentication in the Scalr management system.

## Overview

The Scalr management system uses a three-tier variable hierarchy:
1. **Scalr Provider Configurations** - Cluster-specific connection details and credentials
2. **Environment Variables** - Shared variables across all workspaces in an environment
3. **Workspace Variables** - Workspace-specific configuration

## Authentication Flow

All authentication is handled through **Terraform variables only**. No shell environment variables are used for provider authentication.

### Why No Shell Variables?

Shell variables (category: "shell") are unnecessary because:
- Scalr provider configurations pass credentials as **arguments** directly to the provider
- The `export_shell_variables` option doesn't work for custom providers (only official providers like AWS/Azure/GCP)
- Terraform variables provide the same functionality with better security and traceability

## Provider Configurations

### Proxmox Clusters

Three separate Scalr provider configurations exist, one per Proxmox cluster:

| Provider Config     | Endpoint             | Purpose |
|---------------------|----------------------|---------|
| `proxmox-nexus`     | 192.168.30.30:8006   | Primary homelab cluster |
| `proxmox-matrix`    | 192.168.3.5:8006     | Secondary cluster |
| `proxmox-quantum`   | 192.168.10.2:8006    | Development cluster |

**Each provider configuration contains:**
- `endpoint` - API URL for the cluster
- `username` - Proxmox username (format: username@realm)
- `password` - Proxmox password
- `insecure` - Allow self-signed certificates (true for all clusters)
- `ssh_agent` - Enable SSH agent (false for CI/CD mode)
- `ssh.username` - SSH username for host connections ("terraform")
- `ssh.private_key` - SSH private key (from `proxmox_ssh_key` variable)

**Why separate configurations?**
- Each cluster has unique credentials (username/password)
- Provider configurations are static and cannot use dynamic values from workspace variables
- Workspaces reference the specific cluster config they need

**Defined in:** `provider-configurations.tf`  
**Configured in:** `terraform.auto.tfvars` (gitignored)

## Variable Hierarchy

### 1. Environment Variables (Homelab)

These variables are inherited by **all workspaces** in the homelab environment:

| Variable                  | Value       | Type      | Purpose |
|---------------------------|-------------|-----------|---------|
| `proxmox_ssh_key`         | (sensitive) | terraform | SSH private key for template operations |
| `proxmox_ssh_username`    | terraform   | terraform | SSH username for host connections |
| `proxmox_insecure`        | true        | terraform | Allow self-signed certificates |
| `proxmox_ssh_agent`       | false       | terraform | Disable SSH agent (use private key) |

**Why environment-level?**
- Values are identical across all homelab workspaces
- Reduces duplication and ensures consistency
- Single source of truth for shared configuration

**Defined in:** `environments.tf`

### 2. Workspace Variables (Auto-Generated)

These variables are **automatically created** for each workspace based on its provider configuration attachment. Values come from `terraform.auto.tfvars` (gitignored), not hardcoded in YAML.

| Variable              | Source | Example Value | Sensitive |
|-----------------------|--------|---------------|----------|
| `proxmox_endpoint`    | `var.proxmox_clusters[<cluster>].endpoint` | https://192.168.30.30:8006 | No |
| `proxmox_username`    | `var.proxmox_clusters[<cluster>].username` | root@pam | Yes |
| `proxmox_password`    | `var.proxmox_clusters[<cluster>].password` | (hidden) | Yes |
| `proxmox_node`        | YAML definition | bravo/foxtrot/lloyd | No |

**Why workspace-level?**
- Credentials differ per cluster (nexus has different password than matrix/quantum)
- Keeps sensitive values in gitignored `terraform.auto.tfvars` instead of YAML
- Automatically injected based on workspace's provider configuration reference

**Auto-generated in:** `workspaces.tf` (reads from `terraform.auto.tfvars`)  
**Node name defined in:** `data/environments/homelab.yaml`

## Configuration Files

### Core Files

- **`environments.tf`** - Defines environments and environment-level variables
- **`workspaces.tf`** - Creates workspaces and workspace-level variables from YAML
- **`provider-configurations.tf`** - Defines Scalr provider configurations for Proxmox clusters
- **`locals.tf`** - Transforms YAML data into Terraform data structures

### Data Files

- **`data/environments/homelab.yaml`** - Homelab environment and workspace definitions
- **`data/environments/cloud.yaml`** - Cloud environment and workspace definitions
- **`terraform.auto.tfvars`** (gitignored) - Sensitive credentials and cluster configurations

## Variable Categories

Scalr supports two variable categories:

| Category     | Description | Used For |
|--------------|-------------|----------|
| `terraform`  | Terraform input variables | All provider configuration and authentication |
| `shell`      | Environment variables | **NOT USED** - unnecessary for provider auth |

## Best Practices

### ✅ Do

- Use **terraform variables** for all provider configuration
- Store credentials in `terraform.auto.tfvars` (gitignored)
- Use Scalr provider configurations for provider authentication
- Keep environment-level variables for shared configuration
- Let workspace credentials be auto-generated from `terraform.auto.tfvars`
- Only manually define workspace variables for non-sensitive unique values (like `proxmox_node`)
- Document variable purposes and relationships

### ❌ Don't

- Don't use shell variables for provider authentication
- Don't duplicate variables across workspaces when environment-level works
- Don't hardcode sensitive credentials in YAML files
- Don't assume `export_shell_variables` works for custom providers
- Don't manually create workspace variables for credentials (let them be auto-generated)

## Example: How Authentication Works

When a workspace runs:

1. **Workspace references a provider configuration** (e.g., `proxmox-nexus`)
2. **Scalr injects provider configuration as arguments** to the Proxmox provider block
   - This handles the **provider authentication** (username/password sent to provider)
3. **Workspace variables are automatically created** from `terraform.auto.tfvars`
   - `var.proxmox_endpoint`, `var.proxmox_username`, `var.proxmox_password`
   - These are available for **use in your Terraform code** (not for provider auth)
4. **Environment variables are inherited** as `var.proxmox_ssh_key`, `var.proxmox_insecure`, etc.
5. **Workspace-specific variables** like `var.proxmox_node` target specific hosts
6. **SSH operations use** the private key from environment variable

No shell variables are involved - everything flows through Terraform's variable system.

### Dual Authentication Flow

You might notice credentials appear in two places:

1. **Scalr Provider Configuration** - Injects into `provider "proxmox" {}` block
   - Used for provider authentication to Proxmox API
2. **Workspace Variables** - Available as `var.proxmox_username` and `var.proxmox_password`
   - Used by your Terraform code when needed

Both pull from the same source (`terraform.auto.tfvars`), ensuring consistency.

## Maintenance

### Adding a New Cluster

1. Add cluster definition to `terraform.auto.tfvars`:
   ```hcl
   proxmox_clusters = {
     "new-cluster" = {
       endpoint  = "https://192.168.x.x:8006"
       username  = "root@pam"
       password  = "password"
       insecure  = true
       ssh_agent = false
     }
   }
   ```

2. Scalr will automatically create `proxmox-new-cluster` provider configuration

3. Reference in workspace YAML:
   ```yaml
   provider_configs:
     - proxmox-new-cluster
   variables:
     - key: proxmox_node
       value: hostname
   ```

### Adding Environment-Level Variables

Edit `environments.tf` and add a new `scalr_variable` resource following the existing pattern.

### Adding Workspace Variables

**For manually-defined variables:** Edit the appropriate YAML file in `data/environments/` and add variables to the workspace definition.

**For cluster credentials:** Update `terraform.auto.tfvars` with the cluster details. The credentials will be automatically injected into workspaces that use that cluster's provider configuration.

## Troubleshooting

### Provider authentication fails

- Check that provider configuration exists in Scalr UI
- Verify credentials in `terraform.auto.tfvars`
- Ensure workspace references correct provider config

### SSH operations fail

- Verify `proxmox_ssh_key` environment variable is set
- Check that SSH username exists on Proxmox host
- Ensure SSH user has proper sudo permissions

### Variables not appearing

- Run `tofu plan` to see if variables are in configuration
- Check variable category (must be `terraform`, not `shell`)
- Verify environment/workspace relationships in YAML files
- For auto-generated credentials, ensure cluster is defined in `terraform.auto.tfvars`
- For auto-generated credentials, verify workspace has provider configuration attached

## References

- [Scalr Provider Configurations Documentation](https://docs.scalr.io/en/latest/provider_configurations.html)
- [Scalr Variables Documentation](https://docs.scalr.io/en/latest/variables.html)
- [Proxmox Provider Documentation](https://registry.terraform.io/providers/bpg/proxmox/latest/docs)
