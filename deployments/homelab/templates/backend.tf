# =============================================================================
# = Scalr Remote Backend Configuration ========================================
# =============================================================================
# This backend configuration enables CLI-driven workflow with Scalr.
# Runs are executed remotely on Scalr infrastructure but triggered locally.
#
# Prerequisites:
# 1. Authenticate with Scalr: `tofu login the-mothership.scalr.io`
# 2. Ensure workspace exists and is CLI-driven (no vcs_repo configured)
# 3. Provider configurations and variables are configured in Scalr workspace
#
# Usage:
# - `tofu init` - Initialize and configure remote backend
# - `tofu plan` - Create plan (runs on Scalr, shows output locally)
# - `tofu apply` - Apply changes (runs on Scalr)
#
# Benefits:
# - State stored securely on Scalr
# - Execution on Scalr infrastructure (with provider configs)
# - Variables and secrets managed in Scalr
# - Manual control over when runs execute

terraform {
  backend "remote" {
    hostname     = "the-mothership.scalr.io"
    organization = "homelab"

    workspaces {
      name = "vm-templates-nexus"
    }
  }
}
