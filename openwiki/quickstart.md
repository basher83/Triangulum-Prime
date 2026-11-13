---
type: task-routing
title: Quickstart and task routing
description: Choose the configuration root and execution context before changing Scalr account configuration, deploying Proxmox templates, or experimenting locally. Routes engineers to validation and recovery guidance without treating setup as a harmless check.
tags: [quickstart, routing, opentofu, scalr, proxmox]
verified:
  - by: openwiki/0.9.0
    at: 2026-11-12T08:01:26.797Z
sources:
  - id: openwiki-source-9c06bd9d7d25770709e07c7c
    resource: repo://.mise.toml
  - id: openwiki-source-f5053717be48e08d375c2ebc
    resource: repo://.opentofu-version
  - id: openwiki-source-f4ea58552bf95821c57a3374
    resource: repo://deployments/homelab/templates/backend.tf
  - id: openwiki-source-f062fd85b6c0d801a9b89d28
    resource: repo://deployments/homelab/templates/main.tf
  - id: openwiki-source-6ba7300b9dc92f87965faaa9
    resource: repo://deployments/homelab/templates/provider.tf
  - id: openwiki-source-410c80f3e01396616249b67e
    resource: repo://examples/single-vm/main.tf
  - id: openwiki-source-d85920551ae10c239befee0d
    resource: repo://examples/single-vm/provider.tf
  - id: openwiki-source-23775c3de52f3ab95a13cb8b
    resource: repo://README.md
  - id: openwiki-source-67fda28911ed2eca6915ba4f
    resource: repo://scalr-management/data/environments/cloud.yaml
  - id: openwiki-source-7a2c965eb60ce8a47207ce20
    resource: repo://scalr-management/data/environments/homelab.yaml
  - id: openwiki-source-f27b432561bb6aedbaf396a9
    resource: repo://scalr-management/locals.tf
  - id: openwiki-source-1b322a2b07215da0da15f263
    resource: repo://scalr-management/main.tf
  - id: openwiki-source-f920c42fbce563c055fd03b0
    resource: repo://scalr-management/workspaces.tf
  - id: openwiki-source-76f3d337b59570f380794dd4
    resource: repo://scripts/deploy.sh
  - id: openwiki-source-01fdccb5e1355304682f20d6
    resource: repo://scripts/local-test.sh
  - id: openwiki-source-28e45ae11fe7f64787d962f1
    resource: repo://scripts/opentofu-migrate.sh
generated: { by: "openwiki/0.9.0", at: "2026-11-12T08:01:26.797Z" }
---

# Quickstart and task routing

> **Stop before running infrastructure commands.** VCS blocks are commented out in the current environment YAML, and every declared workspace has `auto_apply: false`. Do not expect a push to deploy anything. The template root's backend explicitly selects **`vm-templates-nexus`**, not whichever cluster you intended to target. Review that binding before initialization or planning. See [homelab YAML](../scalr-management/data/environments/homelab.yaml), [cloud YAML](../scalr-management/data/environments/cloud.yaml), and [template backend](../deployments/homelab/templates/backend.tf).

## Choose the task, then the root

Follow this order; creating a Scalr workspace is not the same operation as deploying its workload.

| Task | Root and execution context | Next guide |
| --- | --- | --- |
| **1. Understand ownership** | Separate account configuration, workload roots, and reusable modules before editing. | [System ownership and source map](architecture/system-map.md) |
| **2. Change Scalr account configuration** | `scalr-management/` manages Scalr environments, workspaces, provider configurations, and variables. Environment YAML is loaded into resource definitions. Its remote backend is commented out; do not assume this root runs through a workload workspace. | [Manage Scalr](workflows/manage-scalr.md), then [Scalr configuration model](concepts/scalr-configuration.md) |
| **3. Deploy templates remotely** | `deployments/homelab/templates/` uses the Scalr remote backend. CLI-triggered plans and applies execute remotely, with workspace variables and provider attachments. The current selection is Nexus. | [Provision Proxmox](workflows/provision-proxmox.md) |
| **4. Experiment with a local example** | `examples/single-vm/` declares its own Proxmox provider using input variables and environment authentication. It calls `terraform-bgp-vm` in clone mode, so choose an existing template and target node; this is not the template deployment root. | [Provision Proxmox](workflows/provision-proxmox.md), then [VM and LXC contracts](concepts/proxmox-module-contracts.md) |
| **5. Validate a change** | Check the actual root you edited, not an assumed repository-wide `terraform/` directory. | [Local validation and coverage](testing/local-validation.md) |
| **6. Recover or troubleshoot** | Establish the backend, workspace, and state owner before changing state or retrying an apply. | [State safety and troubleshooting](operations/state-and-troubleshooting.md) |

For credentials, SSH, agent reachability, and external prerequisites, use [Authentication and connectivity](integrations/authentication-and-connectivity.md) before either remote deployment or local experimentation.

The template orchestrator currently enables Ubuntu 24.04; its Ubuntu 22.04 module call is commented out. Do not infer active deployments from directory names alone. See [the orchestrator](../deployments/homelab/templates/main.tf).

## Start with non-mutating checks

From the repository root, with OpenTofu already installed, these are inspection/check commands—not installation, initialization, or infrastructure runs:

```sh
cat .opentofu-version
tofu version
tofu fmt -check -diff -recursive scalr-management
tofu fmt -check -diff -recursive deployments/homelab/templates
tofu fmt -check -diff -recursive examples/single-vm
```

**Repository pin: OpenTofu `1.10.0`.** A provider file's broader `required_version` constraint is not the repository pin. [`.mise.toml`](../.mise.toml) declares `terraform-docs` `0.21.0`, `tflint` `0.61.0`, and `git-cliff` `2.10.1`, but does not install OpenTofu through its `[tools]` table. These are declared requirements, not evidence of a successfully executed toolchain; no commands were executed for this page.

Do **not** use the mise tasks as a ready-to-run bootstrap: `fmt-check`, `tofu-validate`, and `docs-check` target a missing `terraform/` working directory. Mise also enables automatic installation. The validation task includes initialization, and the lint tasks initialize plugins; neither belongs in the non-mutating checks above.

## Cross each side-effect boundary deliberately

- **Installation and authentication:** prepare the pinned toolchain and credentials separately from checking source. Do not expose secret-bearing variable files or state while gathering diagnostics.
- **Initialization:** select the root and backend first. `tofu init` is setup with local/backend effects, not a formatting check. Even backend-disabled initialization can install dependencies.
- **Remote plan:** in the template root, `tofu plan` submits work to Scalr; it is not merely local static validation. Confirm workspace, target cluster, provider attachments, and connectivity first.
- **Apply:** use the relevant workflow and review the plan. `auto_apply: false` does not make a deliberate apply harmless.
- **State migration or destroy:** use the recovery guide and a reviewed change plan; neither is a quickstart step. The management root's commented backend includes migration instructions, not an already-enabled remote backend.

The files under `scripts/`—`deploy.sh`, `local-test.sh`, and `opentofu-migrate.sh`—contain only a shebang and a descriptive comment. They are placeholders, not deployment, test, or recovery workflows.
