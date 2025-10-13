# Scalr Management

YAML-driven Scalr account management for Triangulum-Prime infrastructure.

## Overview

This directory contains Terraform/OpenTofu code to manage your Scalr account configuration as code, including:

-   **Environments**: Logical isolation for homelab vs cloud infrastructure
-   **Workspaces**: Individual deployments (VMs, clusters, containers)
-   **Provider Configurations**: Centralized credentials for Proxmox, DigitalOcean, Hetzner, etc.

## Key Features

-   **YAML-Driven**: Define environments and workspaces in simple YAML files
-   **Multi-Cluster Proxmox Support**: Manage multiple Proxmox clusters from a single configuration
-   **Solo-Optimized**: No IAM complexity (teams/roles) - designed for single operators
-   **Environment Isolation**: Separate homelab and cloud infrastructure
-   **VCS-Backed**: Workspaces automatically sync with GitHub repositories
-   **Centralized Credentials**: Provider configurations shared across workspaces

## Directory Structure

```text
scalr-management/
├── main.tf                         # Scalr provider configuration
├── versions.tf                     # Terraform version constraints
├── variables.tf                    # Input variables
├── outputs.tf                      # Useful outputs
├── locals.tf                       # YAML decoding logic
├── provider-configurations.tf      # Provider credential configs
├── environments.tf                 # Environment resources
├── workspaces.tf                   # Workspace resources
├── data/
│   ├── environments/
│   │   ├── homelab.yaml           # Homelab workspaces
│   │   └── cloud.yaml             # Cloud workspaces
│   └── provider-configs.yaml      # Optional provider configs
└── README.md                       # This file
```

## Quick Start

### 1. Prerequisites

-   OpenTofu >= 1.8.0 (or Terraform >= 1.8.0)
-   Scalr account (free tier available at https://scalr.com)
-   GitHub account with VCS provider configured in Scalr

### 2. Configure Authentication

Set up Scalr credentials using one of these methods:

**Option A: Environment Variables**

```bash
export SCALR_HOSTNAME="your-account.scalr.io"
export SCALR_TOKEN="your-scalr-api-token"
```

**Option B: CLI Login**

```bash
tofu login your-account.scalr.io
# or
terraform login your-account.scalr.io
```

### 3. Create Variable File

Create `terraform.tfvars` (or `.auto.tfvars`) with your configuration:

```hcl
# Scalr Account
account_id = "acc-xxxxxxxxxxxx"

# VCS Provider (GitHub)
vcs_provider_id = "vcs-xxxxxxxxxxxx"

# Proxmox Configuration (Multi-Cluster Support)
proxmox_clusters = {
  "prod" = {
    endpoint  = "https://pve-prod.example.com:8006/"
    api_token = "terraform@pve!provider=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
    insecure  = false
  }
  "dev" = {
    endpoint  = "https://pve-dev.example.com:8006/"
    api_token = "terraform@pve!provider=yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy"
  }
  "lab" = {
    endpoint = "https://pve-lab.local:8006/"
    username = "root@pam"
    password = "your-password"
    insecure = true
  }
}

# DigitalOcean (Optional)
digitalocean_token = "dop_v1_xxxxxxxxxxxx"

# Hetzner Cloud (Optional)
hetzner_token = "xxxxxxxxxxxxxxxxxxxxxxxxxx"

# Infisical (Optional)
infisical_client_id     = "xxxxxxxxxxxx"
infisical_client_secret = "xxxxxxxxxxxx"
infisical_host          = "https://app.infisical.com"
```

**Security Note**: Never commit `terraform.tfvars` to git. Add it to `.gitignore`.

### 4. Initialize and Apply

```bash
cd scalr-management
tofu init
tofu plan
tofu apply
```

## Managing Environments and Workspaces

### Adding a New Workspace

Edit the appropriate environment YAML file:

**For homelab workspaces**: `data/environments/homelab.yaml`

**For cloud workspaces**: `data/environments/cloud.yaml`

Example - Add a new workspace:

```yaml
workspaces:
    - name: my-new-workspace
      description: Description of the workspace
      auto_apply: false
      terraform_version: "1.10.0"
      execution_mode: remote
      vcs_repo:
          identifier: your-org/triangulum-prime
          path: deployments/homelab/my-new-workspace
          branch: main
      variables:
          - key: my_variable
            value: my_value
            category: terraform
            description: Variable description
```

Then apply the changes:

```bash
tofu apply
```

### Removing a Workspace

1. Delete the workspace definition from the YAML file
2. Run `tofu apply` to remove the workspace from Scalr

### Creating a New Environment

Create a new YAML file in `data/environments/`:

```yaml
name: my-environment
cost_estimation_enabled: false
default_provider_configs:
    - proxmox-cluster1 # Use your actual cluster name
workspaces: []
```

## Multi-Cluster Proxmox Support

This configuration supports managing multiple Proxmox clusters simultaneously. Each cluster is defined in `terraform.tfvars` and automatically gets a provider configuration in Scalr.

### Defining Clusters

In your `terraform.tfvars`, define all your Proxmox clusters:

```hcl
proxmox_clusters = {
  "prod" = {
    endpoint  = "https://pve-prod.example.com:8006/"
    api_token = "terraform@pve!provider=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
    insecure  = false
    ssh_agent = true
  }
  "dev" = {
    endpoint  = "https://pve-dev.example.com:8006/"
    api_token = "terraform@pve!provider=yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy"
    insecure  = false
  }
  "lab" = {
    endpoint  = "https://pve-lab.local:8006/"
    username  = "root@pam"
    password  = "lab-password"
    insecure  = true  # Self-signed cert
    ssh_agent = true
  }
}
```

Each cluster definition supports:

-   **endpoint**: Proxmox API URL (required)
-   **insecure**: Allow self-signed certificates (optional)
-   **ssh_agent**: Enable SSH agent (optional, default: true)
-   **ssh_private_key**: SSH private key for CI/CD pipelines (optional)
-   **Authentication**: Either `api_token` (format: `"username@realm!tokenid=uuid"`) OR `username` + `password`

### SSH Authentication Options

**Option 1: SSH Agent (Recommended for Local Development)**

Default behavior when `ssh_agent = true` or not specified:

```hcl
proxmox_clusters = {
  "prod" = {
    endpoint  = "https://pve-prod.example.com:8006/"
    api_token = "terraform@pve!provider=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
    ssh_agent = true  # Uses your local SSH agent
  }
}
```

**Option 2: SSH Private Key (Required for CI/CD)**

Use when SSH agent forwarding is not available (e.g., CI/CD pipelines):

```hcl
proxmox_clusters = {
  "cicd" = {
    endpoint        = "https://pve-cicd.example.com:8006/"
    api_token       = "terraform@pve!cicd=yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy"
    ssh_agent       = false
    ssh_private_key = file("~/.ssh/id_rsa")  # Load from file
  }
}
```

**Requirements for SSH Private Key:**

-   Must be unencrypted (no passphrase)
-   Must be in PEM format (OpenSSH format)
-   Can be loaded using `file()` function
-   Store securely (use environment variables in CI/CD)

**CI/CD Example:**

```hcl
proxmox_clusters = {
  "cicd" = {
    endpoint        = "https://pve.example.com:8006/"
    api_token       = "terraform@pve!cicd=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
    ssh_agent       = false
    ssh_private_key = file("/secrets/proxmox_ssh_key")  # From secret mount
  }
}
```

### Using Clusters in Environments

Clusters are automatically available as `proxmox-{name}` in your YAML files:

```yaml
name: homelab
default_provider_configs:
    - proxmox-prod # Will use the "prod" cluster
    - proxmox-dev # Will use the "dev" cluster
```

### Using Specific Clusters per Workspace

You can override the default cluster for specific workspaces:

```yaml
workspaces:
    # This workspace uses the production cluster
    - name: production-vms
      description: Production VMs on prod cluster
      # Uses default_provider_configs (proxmox-prod)
      vcs_repo:
          identifier: your-org/triangulum-prime
          path: deployments/production

    # This workspace explicitly uses the lab cluster
    - name: testing-vms
      description: Testing VMs on lab cluster
      provider_configurations:
          - proxmox-lab # Override default
      vcs_repo:
          identifier: your-org/triangulum-prime
          path: deployments/testing
```

### Benefits

-   **Separation**: Keep prod, dev, and lab infrastructure separate
-   **Centralized Credentials**: Manage all cluster credentials in one place
-   **Flexible Deployment**: Route workspaces to specific clusters as needed
-   **Easy to Add**: Adding a new cluster just requires updating `terraform.tfvars`

## Workflow

### Local Development to Scalr

1. **Local Testing**:

    ```bash
    cd /path/to/your/deployment
    tofu init
    tofu plan
    tofu apply
    ```

2. **Enable Scalr Backend**:
   Add to your deployment's Terraform configuration:

    ```hcl
    terraform {
      backend "remote" {
        hostname     = "your-account.scalr.io"
        organization = "your-account-name"
        workspaces {
          name = "workspace-name"
        }
      }
    }
    ```

3. **Migrate State**:
    ```bash
    tofu init -migrate-state
    ```

### Using Scalr Remote Backend for This Configuration

After initial setup, you can manage this Scalr configuration itself in Scalr:

1. Create a workspace in Scalr UI named `scalr-management`
2. Uncomment the backend block in `main.tf`
3. Run `tofu init -migrate-state`

## Provider Configurations

Provider configurations are defined in `provider-configurations.tf` and allow you to centrally manage credentials for:

-   **Proxmox**: Multiple cluster support - each cluster gets its own provider configuration
-   **DigitalOcean**: API token and Spaces credentials
-   **Hetzner**: Cloud API token
-   **Infisical**: Machine identity credentials

These configurations can be:

-   Set as defaults for environments
-   Shared across multiple workspaces
-   Overridden at the workspace level if needed

See the [Multi-Cluster Proxmox Support](#multi-cluster-proxmox-support) section for details on managing multiple Proxmox clusters

## Environment Variables

### Environment-Level Variables

Defined in `environments.tf`, these apply to all workspaces in an environment:

```hcl
resource "scalr_variable" "homelab_default_tags" {
  key          = "TF_VAR_default_tags"
  value        = jsonencode({...})
  environment_id = scalr_environment.environments["homelab"].id
}
```

### Workspace-Level Variables

Defined in YAML workspace definitions:

```yaml
variables:
    - key: vm_template_id
      value: "2006"
      category: terraform # or "shell" for env vars
      sensitive: false
```

## Outputs

After applying, useful outputs include:

-   `environments`: Map of environment names to IDs
-   `workspaces`: Detailed workspace information
-   `workspaces_by_environment`: Workspaces grouped by environment
-   `provider_configurations`: Provider configuration IDs
-   `summary`: High-level summary of managed resources

View outputs:

```bash
tofu output
tofu output -json > outputs.json
```

## Troubleshooting

### VCS Repository Not Found

Ensure:

1. VCS provider is configured in Scalr
2. Repository identifier format is correct: `owner/repo`
3. Scalr has access to the repository
4. Branch name is correct

### Provider Configuration Errors

Check:

1. Provider credentials are correct in `terraform.tfvars`
2. Provider configuration name matches what's referenced in YAML
3. Provider is conditionally created (e.g., `digitalocean_token != null`)

### Workspace Creation Failures

Verify:

1. Environment exists before creating workspaces
2. VCS provider ID is set correctly
3. Repository path exists in your VCS
4. Terraform version is compatible

## Best Practices

1. **Use Auto-Apply Carefully**: Only enable for stable, well-tested workspaces
2. **Version Pin**: Specify `terraform_version` in workspace definitions
3. **Backup State**: Keep backups of your Scalr management state
4. **Use Branches**: Test changes in feature branches before merging to main
5. **Document Variables**: Always add descriptions to workspace variables
6. **Sensitive Data**: Mark sensitive variables appropriately in YAML

## Security Considerations

### Cluster Names in State

**Important**: Cluster names (keys in `proxmox_clusters`) will be visible in:
- Terraform state file
- Resource addresses (e.g., `scalr_provider_configuration.proxmox_clusters["prod"]`)
- Plan output

While the sensitive credentials (API tokens, passwords, SSH keys) are properly marked as sensitive and hidden, the cluster names themselves are not.

**Best practices:**
- Use generic names like "prod", "dev", "lab" instead of revealing hostnames
- Don't use cluster names that expose internal network information
- The actual endpoints and credentials remain protected

**Example - Good cluster naming:**
```hcl
proxmox_clusters = {
  "primary"   = { endpoint = "https://pve1.internal:8006/" ... }  # ✅ Generic
  "secondary" = { endpoint = "https://pve2.internal:8006/" ... }  # ✅ Generic
}
```

**Example - Avoid exposing details:**
```hcl
proxmox_clusters = {
  "datacenter-nyc-rack42-pve1" = { ... }  # ❌ Too specific
  "10.0.0.50" = { ... }                   # ❌ Exposes IP
}
```

## Related Documentation

-   [Scalr Documentation](https://docs.scalr.com/)
-   [Scalr Provider](https://registry.terraform.io/providers/Scalr/scalr/latest/docs)
-   [Triangulum-Prime Modules](../terraform-bgp-vm/README.md)

## License

See LICENSE file in repository root.
