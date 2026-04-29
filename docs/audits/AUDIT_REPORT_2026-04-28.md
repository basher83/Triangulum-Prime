# Documentation Audit Report

Generated: 2026-04-28 | Commit: e9b39ee

## Scope

This audit checked repository-facing markdown against the current filesystem and Terraform/OpenTofu configuration. Generated provider/module documentation under `.terraform/`, historical Claude research reports, and command/agent prompt files under `.claude/` were excluded. Current implementation evidence came from `scalr-management/data/environments/*.yaml`, `scalr-management/*.tf`, deployment `versions.tf` files, module variables and outputs, examples, scripts, and the top-level repository inventory.

## Executive Summary

| Metric | Count |
|--------|-------|
| Repository-facing documents scanned | 35 |
| Concrete claims sampled or verified | approximately 170 |
| Verified false or materially stale claims | 44 |
| Main drift patterns | 5 |

The largest issue is lifecycle drift around Scalr execution. Several docs describe GitHub/VCS-triggered workspaces, but every `vcs_repo` block in both `scalr-management/data/environments/homelab.yaml` and `scalr-management/data/environments/cloud.yaml` is currently commented out with notes saying the repo has switched to CLI-driven execution during debugging. The template workspace README is mostly aligned with that current reality, but the root deployment docs and several per-workspace READMEs still describe automatic push-triggered plans.

The second major issue is stale links and path references. The root README points to missing setup/migration/workflow docs, example READMEs point to missing guides and scripts, and some docs still refer to old `terraform/...` paths that do not exist in this repository layout.

## False Claims Requiring Fixes

### Root README

| Line | Claim | Reality | Fix |
|------|-------|---------|-----|
| `README.md:9` | The repo manages multiple cloud providers including AWS. | No AWS deployment directory, module, provider configuration, or workspace exists. Current cloud code covers DigitalOcean and Hetzner only. | Remove AWS or mark it as future/planned. |
| `README.md:16` | `docs/SETUP.md` exists for setup instructions. | No `docs/SETUP.md` exists. | Create the guide or link to the current setup source. |
| `README.md:20` | `docs/SETUP.md` is a setup guide. | Missing file. | Same as above. |
| `README.md:21` | `docs/MIGRATION.md` exists. | Missing file. | Create it or remove the link. |
| `README.md:22` | `docs/WORKFLOWS.md` exists. | Missing file. | Create it or remove the link. |

### CLAUDE.md

| Line | Claim | Reality | Fix |
|------|-------|---------|-----|
| `CLAUDE.md:113` | Deployment workspaces trigger on changes to their directory. | All `vcs_repo` blocks are commented out in current environment YAML, so workspaces are CLI-driven unless configured elsewhere outside the repo. | Say VCS triggers are currently disabled and describe the CLI-driven flow. |
| `CLAUDE.md:183` | Do not add backend blocks to deployment code because backends are configured at the Scalr workspace level. | `deployments/homelab/templates/backend.tf` contains an active `backend "remote"` block for CLI-driven Scalr execution. | Narrow the rule: most deployments should avoid backend blocks, but template deployment currently uses a Scalr remote backend. |
| `CLAUDE.md:201` | Pushing to VCS triggers the Scalr workspace after local testing. | Current YAML disables VCS integration for all listed workspaces. | Update workflow to queue runs through CLI or re-enable VCS before documenting push-triggered behavior. |
| `CLAUDE.md:217` | All template workspaces trigger on the same directory changes. | Their VCS blocks, including trigger patterns, are commented out. | Say the trigger patterns are staged but disabled. |
| `CLAUDE.md:258` | Scalr triggers automatically on push to the configured branch. | No active VCS repository blocks exist in the current YAML. | Replace with the current CLI-driven behavior or document the re-enable step. |

### Deployment Overview Docs

| Line | Claim | Reality | Fix |
|------|-------|---------|-----|
| `deployments/README.md:24-25` | Each subdirectory corresponds to a Scalr workspace that automatically triggers on directory changes. | VCS is disabled across the environment YAML. | Change to "can correspond" and state current CLI-driven status. |
| `deployments/README.md:42` | `homelab/templates` maps to `homelab/vm-templates`. | Current YAML defines three template workspaces: `vm-templates-matrix`, `vm-templates-nexus`, and `vm-templates-quantum`. | Replace the single row with the three current workspaces. |
| `deployments/README.md:79` | Scalr automatically triggers a plan for the affected workspace after push. | No active `vcs_repo` blocks are configured. | Update workflow to manual/CLI run or explicitly say this only applies after VCS is re-enabled. |
| `deployments/README.md:87-91` | Each workspace only triggers on its specific directory and shared modules trigger dependent workspaces. | Current YAML has no active triggers. Also no module-trigger rules are active. | Convert to intended behavior or future re-enable guidance. |
| `deployments/README.md:135` | No backend block is needed in `.tf` files. | `deployments/homelab/templates/backend.tf` is active. | Add the template exception. |
| `deployments/README.md:141` | Homelab environment variables are `TF_VAR_default_tags` and `TF_VAR_datacenter`. | `environments.tf` defines `proxmox_ssh_key`, `proxmox_ssh_username`, `proxmox_insecure`, and `proxmox_ssh_agent`; `default_tags` and `datacenter` are not environment-level Scalr variables there. | Replace with current environment variables. |
| `deployments/README.md:180-181` | `../modules/README.md` and `../examples/README.md` exist. | Neither file exists. | Create index READMEs or remove these links. |

### Homelab and Cloud Deployment Docs

| Line | Claim | Reality | Fix |
|------|-------|---------|-----|
| `deployments/homelab/README.md:33-34` | Homelab execution is VCS-backed GitHub on `main`. | Homelab workspace `vcs_repo` blocks are commented out. | Describe current CLI-driven execution. |
| `deployments/homelab/README.md:41` | `single-vms` auto-apply is enabled. | `homelab.yaml` has `auto_apply: false` for `single-vms`. | Change to No. |
| `deployments/homelab/README.md:45` | `lxc-containers` auto-apply is enabled. | `homelab.yaml` has `auto_apply: false` for `lxc-containers`. | Change to No. |
| `deployments/homelab/README.md:46` | Template management is a single workspace named `vm-templates`. | Current YAML has three cluster-specific template workspaces. | Replace with the three workspace names. |
| `deployments/cloud/README.md:38` | `digitalocean-droplets` auto-apply is enabled. | `cloud.yaml` has `auto_apply: false`. | Change to No. |
| `deployments/cloud/README.md:40` | `hetzner-instances` auto-apply is enabled. | `cloud.yaml` has `auto_apply: false`. | Change to No. |
| `deployments/cloud/README.md:48-49` | Cloud workspaces are VCS-backed GitHub on `main`. | Cloud workspace `vcs_repo` blocks are commented out. | Describe current CLI-driven state or future desired behavior. |

### Per-Workspace READMEs

| Line | Claim | Reality | Fix |
|------|-------|---------|-----|
| `deployments/homelab/infrastructure/base/README.md:34` | Changes to the directory automatically trigger a Scalr run on push to `main`. | `infra-base` has its `vcs_repo` block commented out. | Say runs are manual/CLI-driven until VCS is re-enabled. |
| `deployments/homelab/vms/single/README.md:32` | Pushes to `main` trigger a Scalr plan. | `single-vms` has no active `vcs_repo`. | Same fix. |
| `deployments/homelab/lxc/README.md:42` | Pushes to `main` trigger a Scalr plan. | `lxc-containers` has no active `vcs_repo`. | Same fix. |
| `deployments/cloud/digitalocean/droplets/README.md:45` | Pushes to `main` trigger a Scalr plan. | `digitalocean-droplets` has no active `vcs_repo`. | Same fix. |

### Example and Module Docs

| Line | Claim | Reality | Fix |
|------|-------|---------|-----|
| `terraform-bgp-lxc/README.md:133` | `../../examples/lxc/main.tf` exists. | No `examples/lxc` directory exists. | Remove the link or add an LXC example. |
| `terraform-bgp-vm/DEFAULTS.md:277` | Module source is `terraform/modules/vm/variables.tf`. | The module lives at `terraform-bgp-vm/variables.tf`. | Update the path. |
| `terraform-bgp-vm/DEFAULTS.md:278` | Examples live under `terraform/deployments/examples/`. | Examples live under `examples/`. | Update the path. |
| `terraform-bgp-vm/README.md:188` | `microk8s-cluster` deploys via a `vm-cluster` module. | `examples/microk8s-cluster/main.tf` uses `for_each` directly with `../../terraform-bgp-vm`. | Replace "vm-cluster module" with direct composition using the VM module. |
| `examples/template-from-file/README.md:3` | The workflow is compatible with `scripts/build-template.sh`. | No `scripts/build-template.sh` exists; current scripts are `deploy.sh`, `local-test.sh`, and `opentofu-migrate.sh`. | Remove the script reference or add the script. |
| `examples/template-from-file/README.md:14` | It works alongside `scripts/build-template.sh`. | Missing script. | Same fix. |
| `examples/template-from-file/README.md:118` | `deployments/testing/*` exists and has an Infisical-style provider. | No `deployments/testing` directory exists. | Remove this note or update to a real deployment path. |
| `examples/template-from-file/README.md:357` | `../../../../docs/terraform/proxmox-vm-provisioning-guide.md` exists. | No `docs/terraform/proxmox-vm-provisioning-guide.md` exists. | Create the guide or remove the link. |
| `examples/template-from-file/README.md:359` | `../../../../scripts/build-template.sh` exists. | Missing script. | Remove or add the script. |
| `examples/template-from-url/README.md:359` | `../../../../docs/terraform/proxmox-vm-provisioning-guide.md` exists. | Missing guide. | Create the guide or remove the link. |
| `examples/single-vm/README.md:512` | Similar VMs should use the `vm-cluster module`. | There is no `vm-cluster` module; the linked MicroK8s example uses `for_each` composition. | Rename to "MicroK8s cluster example" or "composition pattern". |
| `examples/single-vm/README.md:530` | `../../../../CLAUDE.md` links to project docs. | From `examples/single-vm`, that path resolves outside this repo. The correct relative link is `../../CLAUDE.md`. | Fix the relative path. |
| `examples/microk8s-cluster/README.md:380` | `../../../../docs/terraform/proxmox-vm-provisioning-guide.md` exists. | Missing guide. | Create the guide or remove the link. |

### Stale Review Document

| Line | Claim | Reality | Fix |
|------|-------|---------|-----|
| `docs/reviews/2026-02-26-comprehensive-repo-review.md:70` | `vm_template_id` and `vm_count` are strings and should be numbers. | `deployments/homelab/vms/single/variables.tf` now defines both as `number`. | Mark as resolved or archive as historical. |
| `docs/reviews/2026-02-26-comprehensive-repo-review.md:74` | `terraform-bgp-vm/` and `terraform-bgp-lxc/` use singular `output.tf`. | Both modules currently use `outputs.tf`. | Mark as resolved. |
| `docs/reviews/2026-02-26-comprehensive-repo-review.md:78` | All five examples reference `../../../modules/vm`. | Current examples use `../../terraform-bgp-vm`. | Mark as resolved. |

## Pattern Summary

| Pattern | Count | Root Cause |
|---------|-------|------------|
| VCS-triggered workflow claims while YAML disables `vcs_repo` | 12 | Execution mode shifted to CLI-driven debugging but broad docs were not updated. |
| Wrong auto-apply status | 4 | Workspace tables still reflect older intended behavior rather than YAML truth. |
| Missing local doc links and stale path references | 14 | Placeholder docs or old path references were never created after repo layout changed. |
| Missing script references | 3 | Template docs still mention `scripts/build-template.sh`, but current scripts do not include it. |
| Historical review findings now resolved | 3 | The review document is not labeled as a stale snapshot. |

## Verified True Claims Worth Keeping

The core Scalr management implementation is still YAML-driven. `locals.tf` loads `data/environments/*.yaml`, flattens workspaces, defaults `iac_platform` to `opentofu`, and builds provider configuration attachments from either workspace-specific `provider_configs` or environment defaults.

The three Proxmox provider configuration names are supported by code. `provider-configurations.tf` dynamically creates `proxmox-${each.key}`, and `homelab.yaml` references `proxmox-nexus`, `proxmox-matrix`, and `proxmox-quantum`.

The template README is closer to current reality than the broader docs. It correctly says VCS triggers are disabled and describes CLI-driven execution, and `deployments/homelab/templates/backend.tf` confirms the remote Scalr backend for the `vm-templates-nexus` workspace.

The test directory READMEs are accurate as placeholders. No `.tftest.hcl`, Go Terratest files, or `go.mod` were found under `tests/`.

## Human Review Queue

- Decide whether `docs/iac-implementation-plan.md`, `docs/phase-1.md`, and `docs/reviews/2026-02-26-comprehensive-repo-review.md` should be treated as historical snapshots. If so, add a header that says they are not current operating documentation.
- Decide the canonical workspace naming format in docs: bare Scalr workspace name such as `vm-templates-nexus`, or display path such as `homelab/vm-templates-nexus`.
- Decide whether template deployments are the only allowed exception to the no-backend rule, or whether CLI-driven Scalr backends are now the preferred pattern for more deployments.
- Decide whether to create missing index docs (`docs/SETUP.md`, `docs/MIGRATION.md`, `docs/WORKFLOWS.md`, `modules/README.md`, `examples/README.md`) or remove the links until the repo has those guides.

## Validation Notes

While collecting evidence from inside the repo, commands that trigger mise failed before running because `.mise.toml` has duplicate keys: `tflint` appears at lines 15 and 17, and `pre-commit` appears at lines 16 and 18. This is not just documentation drift, but it affects the documented local workflow because `rg` and other shell commands can fail in this directory before the requested executable starts.

No full OpenTofu validation was run as part of this documentation audit because the repo contains many remote/provider-backed workspaces and the objective was claim verification, not infrastructure planning or applying.
