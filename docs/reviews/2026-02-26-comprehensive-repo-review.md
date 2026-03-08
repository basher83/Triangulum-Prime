# Comprehensive Repository Review: Triangulum-Prime

Date: 2026-02-26
Reviewed By: Automated Multi-Agent Analysis
Repository: basher83/Triangulum-Prime
Scope: Full codebase — security, code quality, architecture, simplification

---

## Executive Summary

Triangulum-Prime is a well-architected Infrastructure as Code framework managing multi-cluster Proxmox homelab and multi-cloud infrastructure via OpenTofu and Scalr orchestration. The YAML-driven workspace management pattern is sound and the module design is flexible.

However, the repository is currently a framework rather than a production system. Most deployment directories contain only commented-out example code, VCS triggers are universally disabled, and no automated tests exist.

### Top 5 Actions

1. Enable VCS triggers on at least one workspace to validate GitOps pipeline
2. Mark all sensitive variables with `sensitive = true` across deployment code
3. Deploy real resources (VM, LXC, Droplet) to validate patterns end-to-end
4. Add CI/CD pipeline with `tofu validate`, `tofu fmt`, and security scanning
5. Remove or complete stub modules that create confusion

---

## Overall Assessment

### Strengths

The multi-tier Scalr architecture (Account, Environment, Workspace) is well-designed. The YAML-driven workspace management eliminates significant Terraform boilerplate. The unified VM module supports three creation modes with extensive validation, and the multi-cluster provider alias pattern is scalable. Sensitive variables are properly marked in the Scalr management layer, and `.gitignore` correctly excludes state files and secrets.

### Weaknesses

VCS integration is disabled across all workspaces (CLI-driven only). No production workloads exist; virtually all deployment code is commented examples. No automated tests exist despite the `tests/` directory having placeholder structure (`unit/`, `integration/`, `terratest/` subdirs with README files). No CI/CD pipeline is configured. Security gaps exist in deployment-level variable definitions, and several modules under `modules/shared/` and `modules/cloud/` are non-functional stubs.

---

## 1. Security Review

### SEC-01: Unmarked Sensitive Variables in Deployments — CRITICAL

Files: `deployments/homelab/templates/variables.tf` (lines 27-30), `deployments/homelab/templates/ubuntu-24-cloudinit/variables.tf` (lines 36-39)

`proxmox_password` is defined without `sensitive = true` in deployment code, despite being properly marked in `scalr-management/`. Passwords may appear in Terraform plan output and logs.

Fix: Add `sensitive = true` to all password and token variables in deployment code.

### SEC-02: Hardcoded SSH Keys in Cloud-Init — HIGH

File: `deployments/homelab/templates/shared/user-data.yaml` (lines 11-14)

Three SSH public keys are hardcoded in the cloud-init configuration for the `ansible` user. While these are public keys, they reveal infrastructure access patterns and should be managed dynamically.

Fix: Inject SSH keys via Terraform variables instead of hardcoding in YAML.

### SEC-03: Default `insecure = true` Across Homelab — HIGH

Files: `scalr-management/environments.tf` (line 74), `deployments/homelab/templates/variables.tf` (lines 16-18)

TLS certificate verification is disabled by default for all Proxmox connections. While common in homelab environments with self-signed certificates, this should not be the default.

Fix: Change default to `false`. Provide CA certificate configuration instructions.

### SEC-04: Overly Permissive Firewall Rules — HIGH

File: `modules/cloud/digitalocean_firewall/main.tf` (lines 18-30)

DigitalOcean firewall allows inbound from `0.0.0.0/0` for HTTP, HTTPS, and ICMP. Outbound allows all traffic to `0.0.0.0/0` on all protocols.

Fix: Restrict to necessary sources and destinations. Add source address variables.

### SEC-05: Mixed Authentication Strategies — MEDIUM

File: `scalr-management/variables.tf` (lines 30-88)

The configuration supports both API tokens and username/password authentication. Example documentation shows password-based auth with `password = "password"`.

Fix: Deprecate username/password auth. Update examples to use API tokens exclusively.

### SEC-06: Internal IP Addresses in YAML Comments — MEDIUM

File: `scalr-management/data/environments/homelab.yaml` (lines 48-50)

Internal cluster IPs (192.168.30.30, 192.168.3.5, 192.168.10.2) are exposed in comments throughout the YAML configuration and repeated in workspace descriptions.

Fix: Remove specific IPs from comments. Use generic cluster name references.

### SEC-07: Provider Version Constraint Too Loose — MEDIUM

Files: `terraform-bgp-vm/versions.tf`, `terraform-bgp-lxc/main.tf`

Proxmox provider uses `>= 0.84.1` in modules, which will automatically upgrade to any future version, potentially introducing breaking changes.

Fix: Use `~> 0.84` or pin to a specific version. Test upgrades in development first.

### SEC-08: No RBAC Configuration — LOW

No team assignments, policy groups, or role-based access controls are defined in the Scalr configuration. Acceptable for a single-operator homelab but worth noting for future growth.

### Positive Security Findings

Scalr management variables are properly marked `sensitive = true`. The `.gitignore` correctly excludes `*.tfstate`, `*.tfvars`, and `.terraform/`. No state files are committed to the repository. SSH agent vs private key flexibility is properly implemented, and the LXC module validates that an SSH public key isn't accidentally a private key.

---

## 2. Code Quality Review

### CQ-01: Precondition Logic Complexity — MEDIUM

File: `terraform-bgp-vm/main.tf` (lines 234-237)

The mutual exclusion check for `vm_init.user` and `vm_user_data` uses an unnecessarily verbose condition that is functionally correct but harder to reason about than it needs to be.

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

### CQ-02: SSH Key File Safety — HIGH

File: `terraform-bgp-lxc/main.tf` (line 37)

Direct `file()` call on user-provided SSH key path will crash with a cryptic error if the file doesn't exist:

```hcl
keys = [file("${var.user_ssh_key_public}")]
```

Fix: Add `fileexists()` validation or use `try()` wrapper.

### CQ-03: No Test Suite — HIGH

Directory: `tests/` (placeholder structure only — `unit/`, `integration/`, `terratest/` subdirs each contain a README but no actual tests)

No unit tests, integration tests, or Terratest implementations exist despite the directory structure being in place.

Fix: Implement OpenTofu `tftest.hcl` tests for modules. Add a CI pipeline with `tofu validate`.

### CQ-04: Module Path Inconsistency — LOW

Examples reference `../../../modules/vm` but the actual module is at `terraform-bgp-vm/`. Module should either be moved to `modules/vm/` or examples updated to use correct paths.

### CQ-05: Incomplete Cloud and Shared Modules — MEDIUM

Files: `modules/cloud/`, `modules/shared/`

Seven modules are stubs. `digitalocean_droplet`, `hetzner_server`, `shared_compute`, and `digitalocean_firewall` under `modules/cloud/` contain hardcoded examples rather than parameterized resources. `modules/shared/monitoring/main.tf`, `modules/shared/security/main.tf`, and `modules/shared/backup/main.tf` each contain only a single comment line.

Fix: Complete as proper parameterized modules or remove to reduce confusion.

### CQ-06: Inconsistent File Naming — LOW

`output.tf` (singular) is used in `terraform-bgp-vm/` and `terraform-bgp-lxc/`, while `outputs.tf` (plural) is used in `deployments/homelab/templates/`, `examples/`, and `scalr-management/`. Standardize on one convention.

### CQ-07: Variable Type Mismatches — MEDIUM

File: `deployments/homelab/vms/single/variables.tf`

`vm_template_id` and `vm_count` are defined as `type = string` but hold numeric values (defaults `"2006"` and `"3"`). These should be `type = number`.

### CQ-08: Missing Variable Descriptions — MEDIUM

Cloud modules have no variables at all (hardcoded values). Some LXC variables lack descriptions.

### CQ-09: Repeated Proxmox Connection Variables — MEDIUM

The same 8 Proxmox connection variables are repeated in 3+ deployment directories. These should be centralized via Scalr environment-level variables.

### CQ-10: Commented Example Code — MEDIUM

200+ lines of commented-out example code exist across deployment directories. This should be moved to `examples/` or documentation. Git history preserves everything.

### CQ-11: Missing Module READMEs — MEDIUM

The primary module `terraform-bgp-vm` has no README. Several other modules also lack documentation.

### CQ-12: Referenced DEFAULTS.md Doesn't Exist — MEDIUM

Module comments reference `terraform/modules/vm/DEFAULTS.md` which doesn't exist in the repository.

---

## 3. Architecture and Patterns Review

### ARCH-01: Multi-Tier Scalr Architecture — Strength

The three-tier hierarchy is well-designed. Account-level provider configs live in `scalr-management/provider-configurations.tf`, environments are logically separated via YAML (homelab, cloud), and each workspace maps to a deployment directory. The YAML-driven approach eliminates significant Terraform boilerplate.

### ARCH-02: VCS Integration Universally Disabled — CRITICAL

All VCS triggers are commented out across all workspaces in both `homelab.yaml` and `cloud.yaml`:

```yaml
# TEMPORARILY DISABLED: Switched to CLI-driven to avoid burning runs during debugging
```

This breaks the core GitOps workflow. No workspaces respond to git push events.

Fix: Enable VCS on at least `vm-templates-nexus` to validate the pipeline. Progressively enable others.

### ARCH-03: No Active Production Deployments — HIGH

Only the `ubuntu-24-cloudinit` template deployment has actual code. All other deployments (VMs, clusters, LXC, cloud) are commented examples. The codebase is a framework, not a running system.

Fix: Deploy real resources to validate patterns end-to-end.

### ARCH-04: locals.tf Complexity — MEDIUM

The 128-line `scalr-management/locals.tf` performs multi-stage YAML to Terraform transformation with complex conditional logic for trigger patterns, provider configurations, and workspace enrichment. Concerns include high cognitive load, cryptic error messages when the YAML schema is wrong, silent skipping of invalid provider references, and no YAML schema validation.

Fix: Add YAML schema documentation. Consider splitting `locals.tf` into focused files.

### ARCH-05: Root Orchestrator Pattern — Strength

VM templates use a single codebase (`deployments/homelab/templates/`) with three Scalr workspaces targeting different clusters via workspace variables. This is DRY and scalable.

### ARCH-06: Provider Version Inconsistency — MEDIUM

Both `terraform-bgp-vm` and `terraform-bgp-lxc` use `>= 0.84.1` for the Proxmox provider, while `deployments/homelab/templates/` uses `~> 0.89.0`. The modules allow any version above 0.84.1 while the deployment pins to the 0.89.x line.

Fix: Harmonize constraints. Either update module constraints to match deployment or vice versa.

### ARCH-07: VM Module Feature-Complete but Heavyweight — Low

The `terraform-bgp-vm` module is well-designed with 329 lines of variables supporting 3 creation modes, extensive validation, and cloud-init integration. The high variable count creates a steep learning curve for simple use cases.

### ARCH-08: LXC Module Underdeveloped — MEDIUM

The LXC module is significantly simpler than the VM module, lacks cloud-init support, and only supports single network interfaces.

Fix: Add cloud-init support and multi-NIC support to reach parity with the VM module.

### ARCH-09: Cloud Modules Non-Functional — MEDIUM

Cloud modules under `modules/cloud/` are hardcoded example resources, not parameterized modules. They're not used by any deployment.

Fix: Either develop as proper modules or remove.

### ARCH-10: Inter-Workspace Dependencies Undocumented — MEDIUM

An implicit dependency chain exists: infra-base, then vm-templates, then single-vms, then clusters. No explicit dependency enforcement, no state sharing between workspaces, and no validation that prerequisites are met.

Fix: Document dependencies. Consider Scalr run triggers for sequencing.

---

## 4. Code Simplification Opportunities

### SIMP-01: Consolidate Environment Variables — Save ~27 LOC

File: `scalr-management/environments.tf` (lines 46-92)

Four nearly identical `scalr_variable` resources for Proxmox SSH configuration can be consolidated into a single `for_each` resource using a locals map.

### SIMP-02: Remove Commented-Out Code — Save 200+ LOC

Commented example code exists in 7+ deployment directories. Move to `examples/` or documentation.

### SIMP-03: Consolidate Template Variables — Save ~90 LOC

File: `deployments/homelab/templates/variables.tf`

140 lines of near-identical Ubuntu 22/24 variables can be consolidated into a single `map(object(...))` variable.

### SIMP-04: Consolidate Cloud Provider Configurations — Save ~78 LOC

File: `scalr-management/provider-configurations.tf` (lines 131-228)

Three separate cloud provider resources (DigitalOcean, Hetzner, Infisical) share identical structure. Convert to data-driven `for_each` pattern.

### SIMP-05: Simplify YAML Configuration — Save 100+ LOC

Introduce VCS defaults at environment level instead of repeating `identifier`, `branch`, and exclude patterns in every workspace.

### SIMP-06: Centralize Proxmox Connection Variables — Save ~40 LOC

Move repeated Proxmox connection variables to Scalr environment-level instead of defining in each deployment.

### SIMP-07: Delete Legacy Variables

Remove explicitly unused `ubuntu_version` and `debian_version` variables.

### SIMP-08: Fix Variable Types

Change `vm_template_id` and `vm_count` from `string` to `number` in `deployments/homelab/vms/single/variables.tf`.

---

## Consolidated Recommendations

### Immediate

1. SEC-01: Add `sensitive = true` to all password/token variables in deployment code
2. ARCH-02: Enable VCS triggers on `vm-templates-nexus` workspace
3. CQ-02: Add `fileexists()` validation to LXC SSH key file reference
4. SIMP-07: Delete unused legacy variables
5. SIMP-08: Fix variable types

### Short-Term (1-2 Weeks)

6. CQ-03: Create initial test suite with `tofu validate` CI pipeline
7. CQ-09: Centralize Proxmox connection variables via Scalr environment
8. SIMP-02: Remove all commented-out example code from deployments
9. CQ-11: Create README for `terraform-bgp-vm`
10. CQ-05: Remove or complete stub modules

### Medium-Term (1-2 Months)

11. SEC-04: Restrict firewall rules to least-privilege
12. SEC-02: Move SSH keys from hardcoded cloud-init to Terraform variables
13. SIMP-01, SIMP-03, SIMP-04: Consolidate duplicated resources and variables
14. ARCH-10: Document workspace dependencies and add run triggers
15. ARCH-06: Harmonize provider version constraints
16. ARCH-08: Enhance LXC module toward VM module parity

---

This review was generated by automated multi-agent analysis examining the full codebase across security, code quality, architecture, and simplification domains.
