# Comprehensive IaC Repository Structure Plan for Homelab and Multi-Cloud Deployments

## Executive Summary

This document provides a structured implementation plan for organizing Infrastructure as Code (IaC) repositories optimized for Scalr's three-tier hierarchy (Account, Environment, Workspace), local testing workflows, and seamless OpenTofu migration. The plan emphasizes flexible deployments across Proxmox homelab infrastructure and multiple cloud providers while maintaining Terraform/OpenTofu best practices.

## Repository Structure Strategy

### Primary Repository Layout

```text
iac-homelab/
├── scalr-management/                    # Scalr platform management
│   ├── account/
│   │   ├── main.tf                      # Global IAM, policies, credentials
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── versions.tf
│   ├── environments/
│   │   ├── homelab/
│   │   │   ├── environment.tf           # scalr_environment resource
│   │   │   ├── workspaces/              # scalr_workspace resources
│   │   │   │   ├── proxmox-single-vms.tf
│   │   │   │   ├── proxmox-clusters.tf
│   │   │   │   ├── vault-cluster.tf
│   │   │   │   ├── nomad-cluster.tf
│   │   │   │   └── k8s-cluster.tf
│   │   │   └── variables.tf
│   │   ├── cloud-dev/
│   │   │   ├── environment.tf
│   │   │   └── workspaces/
│   │   │       ├── digitalocean-droplets.tf
│   │   │       └── hetzner-instances.tf
│   │   └── cloud-prod/
│   │       └── ...
│   └── provider-configurations/          # Scalr provider configs
│       ├── proxmox.tf
│       ├── digitalocean.tf
│       ├── hetzner.tf
│       └── aws.tf
├── modules/                             # Reusable modules
│   ├── proxmox/
│   │   ├── vm/
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   ├── outputs.tf
│   │   │   └── README.md
│   │   ├── lxc/
│   │   ├── cluster/                     # For Vault, Nomad, K8s clusters
│   │   └── network/
│   ├── cloud/
│   │   ├── digitalocean-droplet/
│   │   ├── hetzner-server/
│   │   └── shared-compute/              # Common patterns
│   └── shared/
│       ├── monitoring/
│       ├── backup/
│       └── security/
├── deployments/                         # Environment-specific deployments
│   ├── local/                          # Local testing configurations
│   │   ├── proxmox-test/
│   │   ├── cloud-test/
│   │   └── backend-local.tf            # Local state for testing
│   ├── homelab/
│   │   ├── proxmox/
│   │   │   ├── single-vms/
│   │   │   │   ├── main.tf
│   │   │   │   ├── terraform.tfvars
│   │   │   │   └── backend-scalr.tf    # Scalr remote backend
│   │   │   ├── vault-cluster/
│   │   │   ├── nomad-cluster/
│   │   │   └── k8s-cluster/
│   │   └── ansible/                    # Ansible playbooks
│   │       ├── inventories/
│   │       ├── playbooks/
│   │       └── roles/
│   ├── cloud-dev/
│   │   ├── digitalocean/
│   │   └── hetzner/
│   └── cloud-prod/
│       └── ...
├── tests/                              # Testing infrastructure
│   ├── unit/
│   │   └── *.tftest.hcl               # OpenTofu unit tests
│   ├── integration/
│   │   └── *.tftest.hcl               # Integration tests
│   └── terratest/                     # Go-based tests (optional)
├── scripts/                           # Automation scripts
│   ├── local-test.sh                  # Local testing workflow
│   ├── deploy.sh                      # Deployment automation
│   └── opentofu-migrate.sh            # Migration helper
├── docs/                              # Documentation
│   ├── SETUP.md
│   ├── MIGRATION.md
│   └── WORKFLOWS.md
├── .opentofu-version                  # OpenTofu version pinning
├── .terraform-version                 # Terraform version (during migration)
└── .mise.toml                         # Mise configuration
```

## Implementation Phases

### Phase 1: Foundation Setup (Week 1-2)

**1.1 Repository Initialization**
- Create the base directory structure
- Initialize git repository with proper .gitignore
- Set up OpenTofu version constraints
- Create basic documentation

**1.2 Module Development**
- Develop Proxmox VM module for single instances
- Create Proxmox LXC module
- Build basic cloud provider modules (DigitalOcean, Hetzner)
- Implement cluster modules for Vault, Nomad, K8s

**1.3 Local Testing Infrastructure**
- Set up local backend configurations for testing
- Create test workspaces for each deployment type
- Implement basic validation and testing scripts

### Phase 2: Scalr Integration (Week 3-4)

**2.1 Scalr Management Setup**
- Configure Scalr Terraform provider
- Create account-level configurations
- Set up provider configurations for each target
- Implement environment structures

**2.2 Workspace Automation**
- Create workspace definitions for each deployment type
- Set up variable inheritance patterns
- Configure VCS integration
- Implement policy frameworks (OPA)

**2.3 Backend Migration**
- Migrate from local to Scalr remote backends
- Test state management and workspace isolation
- Validate variable and credential inheritance

### Phase 3: Advanced Configuration (Week 5-6)

**3.1 Cluster Deployments**
- Implement HashiCorp Vault cluster automation
- Set up Nomad cluster deployment
- Create Kubernetes cluster management
- Integrate service discovery and networking

**3.2 Multi-Cloud Integration**
- Finalize DigitalOcean and Hetzner deployments
- Implement cross-cloud networking where needed
- Set up monitoring and logging across environments
- Create backup and disaster recovery procedures

### Phase 4: OpenTofu Migration (Week 7-8)

**4.1 Migration Preparation**
- Back up all state files
- Update provider versions for compatibility
- Test OpenTofu compatibility in isolated environments
- Create rollback procedures

**4.2 Gradual Migration**
- Migrate test workspaces first
- Update CI/CD pipelines to use OpenTofu
- Migrate production workspaces after validation
- Update documentation and training materials

## Local Development Workflow

### Testing Strategy

**1. Local Development Process**
```bash
# Local testing workflow
cd deployments/local/proxmox-test
tofu init
tofu plan -var-file="test.tfvars"
tofu apply -auto-approve

# Run tests
cd ../../../tests/unit
tofu test

# Integration testing
cd ../integration
tofu test -verbose
```

**2. Scalr Integration Testing**
```bash
# Switch to Scalr backend for final validation
cd deployments/homelab/proxmox/single-vms
tofu init -migrate-state
tofu plan
# Review in Scalr UI before apply
tofu apply
```

### Environment-Specific Variables

**Local Testing (local.tfvars)**
```hcl
# Local testing overrides
proxmox_endpoint = "https://pve-lab.local:8006"
skip_tls_verify = true
test_mode = true
vm_count = 1
```

**Homelab Production (homelab.tfvars)**
```hcl
# Production homelab settings
proxmox_endpoint = var.proxmox_endpoint  # From Scalr variables
vm_count = 3
backup_enabled = true
monitoring_enabled = true
```

## Scalr Three-Tier Integration

### Account Scope Configuration

```hcl
# scalr-management/account/main.tf
resource "scalr_variable" "global_tags" {
  key        = "TF_VAR_default_tags"
  value      = jsonencode({
    Environment = "managed-by-scalr"
    Team        = "homelab"
  })
  category   = "shell"
  account_id = var.scalr_account_id
  final      = true
}

resource "scalr_provider_configuration" "proxmox_homelab" {
  name       = "proxmox-homelab"
  account_id = var.scalr_account_id
  custom {
    provider_name = "telmate/proxmox"
    argument {
      name  = "pm_api_url"
      value = var.proxmox_api_url
    }
    argument {
      name  = "pm_api_token_id"
      value = var.proxmox_token_id
    }
    argument {
      name  = "pm_api_token_secret"
      value = var.proxmox_token_secret
      sensitive = true
    }
  }
}
```

### Environment Scope Configuration

```hcl
# scalr-management/environments/homelab/environment.tf
resource "scalr_environment" "homelab" {
  name       = "homelab"
  account_id = var.scalr_account_id
  
  default_provider_configurations = [
    scalr_provider_configuration.proxmox_homelab.id
  ]
  
  policy_groups = [
    scalr_policy_group.security_baseline.id
  ]
}

resource "scalr_variable" "homelab_region" {
  key            = "TF_VAR_datacenter"
  value          = "homelab-dc1"
  category       = "shell"
  environment_id = scalr_environment.homelab.id
}
```

### Workspace Scope Configuration

```hcl
# scalr-management/environments/homelab/workspaces/proxmox-single-vms.tf
resource "scalr_workspace" "proxmox_single_vms" {
  name           = "proxmox-single-vms"
  environment_id = scalr_environment.homelab.id
  
  vcs_provider_id = data.scalr_vcs_provider.github.id
  vcs_repo {
    identifier = "your-org/iac-homelab"
    branch     = "main"
    path       = "deployments/homelab/proxmox/single-vms"
  }
  
  terraform_version = "1.8.0"  # Will migrate to OpenTofu
  execution_mode    = "local"   # For testing, then "remote"
  
  var_files = [
    "homelab.tfvars"
  ]
  
  # Workspace-specific variables
  variable {
    key      = "vm_template"
    value    = "ubuntu-22.04-template"
    category = "terraform"
  }
}
```

## OpenTofu Migration Strategy

### Pre-Migration Checklist

1. **State Backup**
```bash
# Backup all state files
./scripts/backup-states.sh
```

2. **Compatibility Verification**
```bash
# Test OpenTofu compatibility
tofu init -upgrade
tofu plan
```

3. **Provider Version Alignment**
```hcl
# versions.tf - Updated for OpenTofu
terraform {
  required_version = ">= 1.8.0"
  required_providers {
    proxmox = {
      source  = "bgp/proxmox"
      version = "~> 3.0"
    }
    scalr = {
      source  = "registry.scalr.io/scalr/scalr"
      version = "~> 1.5"
    }
  }
}
```

### Migration Execution

**Step 1: Local Environment Migration**
```bash
cd deployments/local/proxmox-test
tofu init -migrate-state
tofu plan  # Verify no unexpected changes
tofu apply
```

**Step 2: Scalr Workspace Migration**
```bash
# Update Scalr workspace to use OpenTofu
cd scalr-management/environments/homelab/workspaces
tofu apply  # Updates workspace terraform_version to OpenTofu
```

**Step 3: Production Migration**
```bash
# Migrate production workspaces
cd deployments/homelab/proxmox/single-vms
tofu init -migrate-state
tofu plan
tofu apply
```

## Module Design Patterns

### Proxmox VM Module Structure

```hcl
# modules/proxmox/vm/main.tf
resource "proxmox_vm_qemu" "vm" {
  count = var.vm_count
  
  name         = "${var.vm_name_prefix}-${count.index + 1}"
  target_node  = var.proxmox_node
  vmid         = var.vm_id_start + count.index
  
  clone      = var.template_name
  full_clone = true
  
  # Resource allocation
  cores   = var.cpu_cores
  sockets = var.cpu_sockets
  memory  = var.memory_mb
  
  # Networking
  dynamic "network" {
    for_each = var.network_interfaces
    content {
      model   = network.value.model
      bridge  = network.value.bridge
      vlan    = network.value.vlan_tag
    }
  }
  
  # Storage
  dynamic "disk" {
    for_each = var.disks
    content {
      storage = disk.value.storage
      size    = disk.value.size
      type    = disk.value.type
    }
  }
  
  # Cloud-init
  ciuser     = var.ci_user
  cipassword = var.ci_password
  sshkeys    = var.ssh_keys
  ipconfig0  = var.ip_config
  
  lifecycle {
    ignore_changes = [
      network,
      disk,
    ]
  }
}
```

### Cluster Module Pattern

```hcl
# modules/proxmox/cluster/main.tf
module "cluster_nodes" {
  source = "../vm"
  count  = var.cluster_size
  
  vm_name_prefix = "${var.cluster_name}-node"
  vm_count       = 1
  vm_id_start    = var.vm_id_start + count.index
  
  # Cluster-specific configuration
  template_name = var.cluster_template
  cpu_cores     = var.node_cpu_cores
  memory_mb     = var.node_memory_mb
  
  # Networking for cluster communication
  network_interfaces = [
    {
      model     = "virtio"
      bridge    = var.cluster_bridge
      vlan_tag  = var.cluster_vlan
    }
  ]
  
  # Additional configuration via cloud-init
  ci_user = var.cluster_admin_user
  ssh_keys = var.cluster_ssh_keys
}

# Ansible provisioning (post-deployment)
resource "null_resource" "cluster_setup" {
  count = var.enable_ansible_provisioning ? 1 : 0
  
  depends_on = [module.cluster_nodes]
  
  provisioner "local-exec" {
    command = "ansible-playbook -i ${path.module}/inventory ${var.ansible_playbook}"
  }
}
```

## Testing Framework

### Unit Testing with OpenTofu

```hcl
# tests/unit/proxmox-vm.tftest.hcl
variables {
  vm_name_prefix = "test-vm"
  vm_count       = 1
  template_name  = "test-template"
  proxmox_node   = "pve"
}

run "validate_vm_configuration" {
  command = plan
  
  assert {
    condition     = length(proxmox_vm_qemu.vm) == var.vm_count
    error_message = "VM count does not match expected value"
  }
  
  assert {
    condition     = proxmox_vm_qemu.vm[0].name == "${var.vm_name_prefix}-1"
    error_message = "VM naming pattern is incorrect"
  }
}

run "test_invalid_vm_count" {
  command = plan
  
  variables {
    vm_count = -1
  }
  
  expect_failures = [
    var.vm_count
  ]
}
```

### Integration Testing

```hcl
# tests/integration/full-deployment.tftest.hcl
run "deploy_and_test_vm" {
  command = apply
  
  variables {
    vm_name_prefix = "integration-test"
    vm_count       = 1
    template_name  = "ubuntu-22.04-template"
  }
  
  assert {
    condition = length(proxmox_vm_qemu.vm) > 0
    error_message = "No VMs were created"
  }
}

run "verify_vm_accessibility" {
  command = apply
  
  module {
    source = "./test-modules/connectivity-check"
  }
  
  variables {
    vm_ips = [for vm in proxmox_vm_qemu.vm : vm.default_ipv4_address]
  }
}
```

## Automation Scripts

### Local Testing Workflow

```bash
#!/bin/bash
# scripts/local-test.sh

set -e

echo "Starting local testing workflow..."

# Environment setup
export TF_VAR_test_mode=true
cd deployments/local/proxmox-test

# Initialize and validate
tofu init
tofu validate

# Run unit tests
echo "Running unit tests..."
cd ../../../tests/unit
tofu test

# Run integration tests if requested
if [[ "$1" == "--integration" ]]; then
    echo "Running integration tests..."
    cd ../integration
    tofu test -verbose
fi

echo "Testing completed successfully!"
```

### Deployment Automation

```bash
#!/bin/bash
# scripts/deploy.sh

set -e

ENVIRONMENT=${1:-homelab}
COMPONENT=${2:-single-vms}
ACTION=${3:-plan}

echo "Deploying $COMPONENT to $ENVIRONMENT environment..."

cd "deployments/$ENVIRONMENT/proxmox/$COMPONENT"

case $ACTION in
    "plan")
        tofu plan -var-file="${ENVIRONMENT}.tfvars"
        ;;
    "apply")
        tofu apply -var-file="${ENVIRONMENT}.tfvars"
        ;;
    "destroy")
        tofu destroy -var-file="${ENVIRONMENT}.tfvars"
        ;;
    *)
        echo "Invalid action. Use: plan, apply, or destroy"
        exit 1
        ;;
esac
```

## Best Practices and Guidelines

### Code Organization
- Use consistent naming conventions across all components
- Implement proper variable validation in modules
- Document all modules with comprehensive README files
- Use semantic versioning for module releases

### Security Considerations
- Store all sensitive variables in Scalr provider configurations
- Use Scalr's RBAC for access control
- Implement OPA policies for compliance
- Regular credential rotation procedures

### State Management
- Use Scalr remote backend for all production workspaces
- Implement proper state locking mechanisms
- Regular state file backups
- Clear workspace boundaries to prevent state conflicts

### Testing Strategy
- Unit tests for all modules
- Integration tests for complete deployments
- Regular testing in isolated environments
- Automated testing in CI/CD pipelines

## Monitoring and Maintenance

### Operational Dashboards
- Scalr account-level reporting for oversight
- Environment-specific monitoring
- Resource utilization tracking
- Cost management and optimization

### Maintenance Procedures
- Regular OpenTofu/provider updates
- Module version management
- Security patch deployment
- Performance optimization reviews

## Success Metrics

### Technical Metrics
- Deployment success rate (target: >95%)
- Mean time to deployment (target: <10 minutes)
- Test coverage (target: >80%)
- Infrastructure drift detection and remediation

### Operational Metrics
- Developer productivity improvements
- Reduced manual intervention requirements
- Standardization compliance rates
- Security incident reduction

This comprehensive plan provides a structured approach to implementing a scalable, maintainable IaC repository that leverages Scalr's capabilities while supporting your homelab and multi-cloud requirements. The phased implementation ensures manageable progress while maintaining operational stability throughout the migration to OpenTofu.