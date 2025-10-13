# Scalr Management - Infrastructure as Code for Scalr Account Configuration
#
# This configuration manages:
# - Scalr environments (homelab, cloud)
# - Scalr workspaces (VMs, clusters, containers)
# - Provider configurations (Proxmox, DigitalOcean, Hetzner, etc.)
#
# Workflow:
# 1. Test locally: `tofu init && tofu plan`
# 2. Apply changes: `tofu apply`
# 3. Optional: Enable Scalr backend (uncomment below) and migrate with `tofu init -migrate-state`

# Uncomment to use Scalr remote backend (after initial setup)
# terraform {
#   backend "remote" {
#     hostname     = "your-account.scalr.io"
#     organization = "your-account-name"
#     workspaces {
#       name = "scalr-management"
#     }
#   }
# }

provider "scalr" {
  # Hostname and token are automatically read from:
  # - Environment variables: SCALR_HOSTNAME, SCALR_TOKEN
  # - Or CLI credentials: terraform login <hostname>
}
