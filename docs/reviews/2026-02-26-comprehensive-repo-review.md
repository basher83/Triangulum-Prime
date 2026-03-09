# Repository Review: Triangulum-Prime

Date: 2026-02-26
Reviewed By: Automated Multi-Agent Analysis (verified 2026-03-09)
Repository: basher83/Triangulum-Prime
Scope: Full codebase — security, code quality, architecture, simplification

---

## Executive Summary

Triangulum-Prime is a well-architected Infrastructure as Code framework managing multi-cluster Proxmox homelab and multi-cloud infrastructure via OpenTofu and Scalr orchestration. The YAML-driven workspace management pattern is sound and the module design is flexible.

The repository is currently a framework rather than a production system. Most deployment directories contain commented-out example code, VCS triggers are intentionally disabled during development, and no automated tests exist.

---

## Strengths

The multi-tier Scalr architecture (Account, Environment, Workspace) is well-designed. The YAML-driven workspace management eliminates significant Terraform boilerplate. The unified VM module supports three creation modes with extensive validation, and the multi-cluster provider alias pattern is scalable. Sensitive variables are properly marked in the Scalr management layer, and `.gitignore` correctly excludes state files and secrets. The LXC module is fully functional with 48 variables covering startup, networking, disk, mounting, and SSH keys. The root orchestrator pattern for VM templates is DRY and scalable.

---

## Quick Fixes

### SEC-01: Unmarked Sensitive Variables in Deployments

Files: `deployments/homelab/templates/variables.tf` (lines 27-30), `deployments/homelab/templates/ubuntu-24-cloudinit/variables.tf` (lines 36-39)

`proxmox_password` is defined without `sensitive = true` in deployment code, despite being properly marked in `scalr-management/`. Passwords may appear in Terraform plan output and logs.

Fix: Add `sensitive = true` to all password and token variables in deployment code.

### CQ-01: Precondition Logic Complexity

File: `terraform-bgp-vm/main.tf` (lines 234-237)

The mutual exclusion check for `vm_init.user` and `vm_user_data` uses an unnecessarily verbose condition.

Current:

```hcl
condition = ((var.vm_init.user != null && var.vm_user_data == null) ||
             (var.vm_init.user == null && var.vm_user_data != null) ||
             (var.vm_init.user == null && var.vm_user_data == null))
```

Simplified equivalent:

```hcl
condition = !(var.vm_init.user != null && var.vm_user_data != null)
```

### CQ-02: SSH Key File Safety

File: `terraform-bgp-lxc/main.tf` (line 37)

Direct `file()` call on user-provided SSH key path will crash with a cryptic error if the file doesn't exist:

```hcl
keys = [file("${var.user_ssh_key_public}")]
```

Fix: Add `fileexists()` validation or use `try()` wrapper.

### CQ-07: Variable Type Mismatches

File: `deployments/homelab/vms/single/variables.tf`

`vm_template_id` and `vm_count` are defined as `type = string` but hold numeric values (defaults `"2006"` and `"3"`). These should be `type = number`.

### CQ-06: Inconsistent File Naming

`output.tf` (singular) is used in `terraform-bgp-vm/` and `terraform-bgp-lxc/`, while `outputs.tf` (plural) is used in `deployments/homelab/templates/`, `examples/`, and `scalr-management/`. Standardize on one convention.

### CQ-04: Broken Example Module Paths

All 5 examples reference `source = "../../../modules/vm"` but no `modules/vm` directory exists. The actual module is at `terraform-bgp-vm/`. Examples will fail at `tofu init`.

---

## Cleanup Items

### CQ-05: Remove Stub Modules

`modules/shared/monitoring/main.tf`, `modules/shared/security/main.tf`, and `modules/shared/backup/main.tf` each contain only a single comment line. Cloud modules under `modules/cloud/` contain hardcoded example resources rather than parameterized modules and are unused by any deployment.

Fix: Remove stubs entirely. Rebuild as proper modules when needed.

### ARCH-09: Cloud Deployment Stubs

Cloud deployment directories (`deployments/cloud/digitalocean/`, `deployments/cloud/hetzner/`) contain commented-out example resources. Not functional.

Fix: Remove or complete when cloud deployments are needed.

---

## Longer-Term Improvements

### ARCH-02: VCS Integration Disabled

All VCS triggers are commented out across all workspaces in both `homelab.yaml` and `cloud.yaml`:

```yaml
# TEMPORARILY DISABLED: Switched to CLI-driven to avoid burning runs during debugging
```

This is intentional during development. Re-enable progressively when ready to validate the GitOps pipeline, starting with `vm-templates-nexus`.

### CQ-03: No Test Suite

The `tests/` directory has placeholder structure (`unit/`, `integration/`, `terratest/` subdirs with README files) but no actual tests. Worth implementing `tftest.hcl` tests for modules and a CI pipeline with `tofu validate` when the codebase stabilizes.

### ARCH-10: Inter-Workspace Dependencies Undocumented

An implicit dependency chain exists: infra-base, then vm-templates, then single-vms, then clusters. No explicit dependency enforcement or documentation. Worth documenting and considering Scalr run triggers when deploying real workloads.

### SIMP-01: Consolidate Scalr Environment Variables

File: `scalr-management/environments.tf` (lines 46-92)

Four nearly identical `scalr_variable` resources for Proxmox SSH configuration can be consolidated into a single `for_each` resource using a locals map. Saves ~27 LOC.

### SIMP-03: Consolidate Template Variables

File: `deployments/homelab/templates/variables.tf`

Near-identical Ubuntu 22/24 variables can be consolidated into a single `map(object(...))` variable. Saves ~90 LOC.

### SIMP-04: Consolidate Cloud Provider Configurations

File: `scalr-management/provider-configurations.tf` (lines 131-228)

Three separate cloud provider resources (DigitalOcean, Hetzner, Infisical) share identical structure. Convert to data-driven `for_each` pattern. Saves ~78 LOC.

### SIMP-05: YAML VCS Defaults

Introduce VCS defaults at environment level instead of repeating `identifier`, `branch`, and exclude patterns in every workspace definition.

---

This review was generated by automated multi-agent analysis and verified against the codebase on 2026-03-09. Findings that were inaccurate, not applicable, or handled by automation (Renovate for provider versions) have been removed.
