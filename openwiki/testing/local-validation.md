---
type: validation-guide
title: Validation tooling and actual test coverage
description: Explains the declared local checks, their broken path assumptions and side effects, and the difference between static validation, plan review, and missing automated tests.
tags: [testing, opentofu, validation, tooling, coverage]
verified:
  - by: openwiki/0.9.0
    at: 2026-11-12T08:01:26.797Z
sources:
  - id: openwiki-source-6d4b4e707b8d60b6ccfa3425
    resource: repo://.github/workflows/openwiki-update.yml
  - id: openwiki-source-abe85be33e0c4ab4531e2906
    resource: repo://.mise.local.toml
  - id: openwiki-source-9c06bd9d7d25770709e07c7c
    resource: repo://.mise.toml
  - id: openwiki-source-f5053717be48e08d375c2ebc
    resource: repo://.opentofu-version
  - id: openwiki-source-38da4e69f4c6a4be51dee009
    resource: repo://deployments/cloud/digitalocean/droplets/versions.tf
  - id: openwiki-source-93ac82387625013dd8fc86b0
    resource: repo://deployments/cloud/hetzner/instances/versions.tf
  - id: openwiki-source-f4ea58552bf95821c57a3374
    resource: repo://deployments/homelab/templates/backend.tf
  - id: openwiki-source-f062fd85b6c0d801a9b89d28
    resource: repo://deployments/homelab/templates/main.tf
  - id: openwiki-source-6ba7300b9dc92f87965faaa9
    resource: repo://deployments/homelab/templates/provider.tf
  - id: openwiki-source-39fd6912be936e5dd090c88d
    resource: repo://deployments/homelab/templates/ubuntu-24-cloudinit/main.tf
  - id: openwiki-source-6f362bbd67a191411f5c4eb8
    resource: repo://deployments/homelab/templates/ubuntu-24-cloudinit/versions.tf
  - id: openwiki-source-482d2109d396d2eb31a67fd8
    resource: repo://deployments/homelab/templates/versions.tf
  - id: openwiki-source-d5b0d70133ca682be5e4e19a
    resource: repo://deployments/homelab/vms/single/versions.tf
  - id: openwiki-source-8dd5f3fcc6300e003c21f2dc
    resource: repo://docs/audits/AUDIT_REPORT_2026-04-28.md
  - id: openwiki-source-23775c3de52f3ab95a13cb8b
    resource: repo://README.md
  - id: openwiki-source-445584aaf9aa98b823dafeda
    resource: repo://scalr-management/.opentofu-version
  - id: openwiki-source-d1a2fad6a6ebbe6caebd8488
    resource: repo://scalr-management/versions.tf
  - id: openwiki-source-01fdccb5e1355304682f20d6
    resource: repo://scripts/local-test.sh
  - id: openwiki-source-ff6e0cd60deb06a6559be7e9
    resource: repo://terraform-bgp-lxc/main.tf
  - id: openwiki-source-15d2cf70d458caff80608375
    resource: repo://terraform-bgp-vm/main.tf
  - id: openwiki-source-8970fae011a87ea841a37472
    resource: repo://terraform-bgp-vm/variables.tf
  - id: openwiki-source-dfd3db7bb859992fcbe6216e
    resource: repo://terraform-bgp-vm/versions.tf
  - id: openwiki-source-24902707efc0e8fae1d298ba
    resource: repo://tests/integration/README.md
  - id: openwiki-source-9a40a42e6db562ea1061431c
    resource: repo://tests/terratest/README.md
  - id: openwiki-source-da85fde896f6c6bf21228a40
    resource: repo://tests/unit/README.md
generated: { by: "openwiki/0.9.0", at: "2026-11-12T08:01:26.797Z" }
---

# Validation tooling and actual test coverage

## What is actually available

The repository declares formatting, OpenTofu validation, documentation checking, and TFLint tasks in [`.mise.toml`](../../.mise.toml). These declarations are **not a working infrastructure CI pipeline**, and the test directories are placeholders. This page is based on source inspection only: no commands, validation, or tests were executed in this documentation environment, which has no execution tool.

| Entry point | Working directory and command | Actual scope or limitation |
|---|---|---|
| `mise run fmt-check` | `terraform`; `tofu fmt --check --diff --recursive` | Read-only formatting check, but the configured `terraform` directory does not exist. |
| `mise run tofu-validate` | `terraform`; `tofu init -backend=false -input=false >/dev/null && tofu validate` | Same missing directory. Even after correcting the path, this is initialization followed by static validation, not a test or plan. Initialization output is redirected, not initialization side effects. |
| `mise run docs-check` | `terraform`; `terraform-docs --config ../.terraform-docs.yml --output-check .` | Both the working directory and referenced root `.terraform-docs.yml` are absent. Not an operational documentation freshness gate. |
| `mise run tflint` | No task-specific `dir`; normally the repository root when invoked there | Runs `tflint --init`, then `tflint --recursive --color`. No checked-in `.tflint.hcl` was found; do not assume a configured Proxmox ruleset. |
| `mise run tflint-fix` | Same directory behavior | Initializes TFLint, then adds `--fix`; this can change files. |
| `mise run lint` | Empty `[tasks.lint]` table | No command or dependency list is declared. It does not aggregate the other checks. |

The changelog task is separate: `git-cliff -o CHANGELOG.md` writes the changelog; it is not validation. Mise enables automatic tool installation, so even invoking a nominally read-only check through mise can install missing tooling.

The [April audit](../../docs/audits/AUDIT_REPORT_2026-04-28.md) is useful historical context, not a substitute for current configuration. Its duplicate `tflint`/`pre-commit` key finding is obsolete: current `.mise.toml` has a single `tflint` tool key and no `pre-commit` tool entry. The missing-directory problem remains.

## Versions are not uniform across roots

The root [`.opentofu-version`](../../.opentofu-version) and [Scalr management pin](../../scalr-management/.opentofu-version) both declare **1.10.0**. These pins express a selected CLI version; `required_version` expresses compatibility, not an identical pin. Mise requires at least **2024.9.5** and installs **terraform-docs 0.21.0**, **TFLint 0.61.0**, and **git-cliff 2.10.1**. It does not declare an OpenTofu tool entry; ensure a compatible `tofu` binary is available rather than assuming `mise install` supplies it.

Representative current constraints:

| Configuration | `required_version` | Provider constraint |
|---|---|---|
| [`scalr-management`](../../scalr-management/versions.tf) | `>= 1.8.0` | `registry.scalr.io/scalr/scalr` exactly `3.11.0` |
| [Template orchestrator](../../deployments/homelab/templates/versions.tf) and [Ubuntu 24 child](../../deployments/homelab/templates/ubuntu-24-cloudinit/versions.tf) | `>= 1.8` | `bpg/proxmox ~> 0.89.0` |
| [Single-VM deployment](../../deployments/homelab/vms/single/versions.tf) | `>= 1.8.0` | `bpg/proxmox ~> 0.89` |
| [Reusable VM module](../../terraform-bgp-vm/versions.tf) | `>= 1.0` | `bpg/proxmox >= 0.84.1` |
| [Reusable LXC module](../../terraform-bgp-lxc/main.tf) | `>=1.5.0` | `bpg/proxmox >=0.84.1` |
| [DigitalOcean droplets](../../deployments/cloud/digitalocean/droplets/versions.tf) | `>= 1.8.0` | `digitalocean/digitalocean ~> 2.0` |
| [Hetzner instances](../../deployments/cloud/hetzner/instances/versions.tf) | `>= 1.8.0` | `hetznercloud/hcloud ~> 1.45` |

Read constraint expressions literally: `~> 0.89.0` is narrower than `~> 0.89`. The template files still contain an older inline comment about pinning to 0.84.x; the executable expression is `~> 0.89.0`. A module's lower bound does not override a consuming root's tighter constraint or lockfile selection.

## Scoped checks for real directories

Use explicit roots instead of the broken `terraform` task paths. The following are **suggested manual commands**, not evidence of successful runs. Run them from the repository root, and repeat validation separately for each affected root/module:

```sh
# Read-only HCL formatting inspection
tofu -chdir=terraform-bgp-vm fmt -check -diff -recursive
tofu -chdir=terraform-bgp-lxc fmt -check -diff -recursive
tofu -chdir=scalr-management fmt -check -diff

# Initialization is not read-only; inspect the diff afterward
tofu -chdir=terraform-bgp-vm init -backend=false -input=false
tofu -chdir=terraform-bgp-vm validate

# Example deployment-root check, subject to private-registry access
tofu -chdir=deployments/homelab/templates init -backend=false -input=false
tofu -chdir=deployments/homelab/templates validate
```

- **Format check:** `fmt -check -diff` reports differences without rewriting HCL. Omitting `-check` turns formatting into a write operation. Scope recursion deliberately; formatting all directories is not equivalent to validating all roots.
- **Initialization:** `init -backend=false` skips backend initialization, but still downloads modules/providers and writes tooling metadata such as `.terraform/` and potentially `.terraform.lock.hcl`. Use an isolated checkout if necessary and review resulting changes. It does not establish that provider credentials, backend state, or live infrastructure are usable.
- **Validation:** `validate` checks the initialized configuration and schemas. It does not prove that a VM boots, storage supports snippets, SSH works, or a cloud API accepts the requested change.
- **Lint:** inspect the effective TFLint configuration before choosing rules or recommending initialization. There is no repository `.tflint.hcl` to establish plugin policy. `tflint --init` can contact services and install configured plugins; recursive lint is not a deployment test. `--fix` may rewrite files and requires diff review.
- **Documentation:** first supply an intentional terraform-docs configuration and real target directories. The current `docs-check` is not a ready-made gate to recommend unchanged.

### Dependencies that can block checks

The active template orchestrator calls the Ubuntu 24 child, which retrieves `the-mothership.scalr.io/proxmox/vm/bgp` at version `1.0.1`. Initialization therefore depends on private-registry connectivity and authentication even with `-backend=false`. A cached `.terraform` directory is not proof that a clean checkout can initialize or that the private module equals the current local VM module.

Local runs also need the intended variable values and file paths. The template child uploads `var.user_data_file`; the LXC module evaluates `file(var.user_ssh_key_public)` when a key path is supplied. Provider operations need appropriate Proxmox/API/SSH configuration. The repository's `.mise.local.toml` defines Scalr and Proxmox environment settings, including credential values; treat that file as sensitive, never copy its values into logs or documentation, and do not assume it supplies every workspace input or authenticates the module registry.

Do not turn validation into a plan/apply accidentally. The [template backend](../../deployments/homelab/templates/backend.tf) selects Scalr's remote backend at `the-mothership.scalr.io`, organization `homelab`, workspace `vm-templates-nexus`. Its documented CLI-driven plan/apply executes remotely. Normal backend initialization, remote planning, and applying change the execution context and state interaction; applying can change infrastructure. Review workspace selection and variables separately from backend-disabled checks. See [Scalr management](../workflows/manage-scalr.md) and [state and troubleshooting](../operations/state-and-troubleshooting.md).

## Actual test and automation coverage

[`tests/unit`](../../tests/unit/README.md), [`tests/integration`](../../tests/integration/README.md), and [`tests/terratest`](../../tests/terratest/README.md) contain **only README placeholders**. There are no implemented `.tftest.hcl` tests, Go tests, or Go harness in those directories. [`scripts/local-test.sh`](../../scripts/local-test.sh) is only a shebang and comment, with no executable testing logic. Neither `tofu test` nor Terratest is existing coverage here.

The only checked-in GitHub workflow is [OpenWiki Update](../../.github/workflows/openwiki-update.yml). It runs manually or on the daily `0 8 * * *` schedule, installs Node/OpenWiki, updates documentation, and creates an update PR. It deliberately preserves completed documentation after an OpenWiki failure before propagating failure status. It does **not** run OpenTofu formatting, validation, lint, plans, or infrastructure tests, and has no infrastructure PR/push gate.

Documentation gaps are also relevant to safe validation: the root README links to missing `docs/SETUP.md`, `docs/MIGRATION.md`, and `docs/WORKFLOWS.md`. `modules/README.md`, `examples/README.md`, and the referenced `docs/terraform/proxmox-vm-provisioning-guide.md` are absent too. Do not treat these targets as working setup or module guides. Start with the [wiki quickstart](../quickstart.md) and [Proxmox workflow](../workflows/provision-proxmox.md), checking commands against the actual root being changed.

## Change-review checklist

These are manual review recommendations, **not present automated coverage**:

1. Identify the affected deployment roots and consuming modules. Check pins, provider constraints, and lockfile diffs; do not validate just a reusable module when its callers changed.
2. Run scoped formatting checks and initialized validation where dependencies permit. Record command, working directory, tool version, and blockers; report an authentication failure as a blocker, not a passing check.
3. Review the [VM module contracts](../concepts/proxmox-module-contracts.md). Implemented lifecycle preconditions require `src_clone` for clones, `src_file` for image creation, and an EFI disk with `ovmf`; they reject simultaneous `vm_init.user` and `vm_user_data`. Disk validation permits at most one `main_disk`. Check these explicitly in input and plan review rather than assuming static validation exercised every value-dependent condition.
4. Review create/replace/destroy actions, VM/container IDs, target node, storage, networking, and startup behavior. VM lifecycle ignores cloud-init user-account and template changes; do not expect these changes to reconcile normally. For LXC, review optional mount points, SSH key file handling, and the conditional startup block (`start_on_boot`).
5. For templates, review snippet upload, image download inputs, EFI disk, and `on_deploy = false` / `on_boot = false`. Verify the intended Scalr workspace and credentials before requesting a remote plan; approve apply separately.

**Recommended future coverage:** repair mise task paths and documentation configuration; define an explicit lint aggregate and plugin policy; add isolated positive/negative contract tests for VM preconditions and disk rules; test LXC optional-block rendering; and introduce separately authorized integration tests for template creation and cloning. A future infrastructure PR workflow should make static checks distinct from credentialed plans and destructive tests. None of those recommendations should be counted as current automation.
