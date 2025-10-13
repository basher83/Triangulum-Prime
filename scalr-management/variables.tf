# ============================================================================
# Scalr Account Variables
# ============================================================================

variable "account_id" {
  description = "Scalr account ID (format: acc-xxxxxxxxx)"
  type        = string
  sensitive   = true

  validation {
    condition     = can(regex("^acc-", var.account_id))
    error_message = "The account_id must be a valid Scalr account ID starting with 'acc-'"
  }
}

# ============================================================================
# VCS Provider Variables
# ============================================================================

variable "vcs_provider_id" {
  description = "Scalr VCS provider ID for GitHub integration"
  type        = string
  default     = null
}

# ============================================================================
# Proxmox Provider Configuration Variables (Multi-Cluster Support)
# ============================================================================

variable "proxmox_clusters" {
  description = <<-EOT
    Map of Proxmox clusters with their connection details.
    Each cluster needs:
    - endpoint: API URL (required)
    - insecure: Allow self-signed certs (optional)
    - ssh_agent: Enable SSH agent (optional, true for local, false for CI/CD)
    - auth: Either api_token OR username/password

    API Token format: "username@realm!tokenid=uuid"
    Example: "terraform@pve!provider=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

    SSH Authentication:
    - Use ssh_agent = true for local development (uses local SSH agent)
    - Use ssh_agent = false for CI/CD (uses var.proxmox_ssh_key)
    - SSH private key is set separately via var.proxmox_ssh_key

    Example:
    {
      "prod" = {
        endpoint   = "https://pve-prod.example.com:8006/"
        api_token  = "terraform@pve!provider=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
        ssh_agent  = true
      }
      "cicd" = {
        endpoint  = "https://pve-cicd.example.com:8006/"
        api_token = "terraform@pve!cicd=yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy"
        ssh_agent = false  # Will use var.proxmox_ssh_key
      }
      "dev" = {
        endpoint = "https://pve-dev.example.com:8006/"
        username = "root@pam"
        password = "password"
        insecure = true
      }
    }
  EOT

  type = map(object({
    endpoint  = string
    insecure  = optional(bool)
    ssh_agent = optional(bool)
    api_token = optional(string)
    username  = optional(string)
    password  = optional(string)
  }))

  # Note: Cannot mark as sensitive because it's used in for_each
  # Individual sensitive fields (api_token, password) are marked sensitive in provider config
  sensitive = false

  validation {
    condition = alltrue([
      for name, cluster in var.proxmox_clusters :
      cluster.api_token != null || (cluster.username != null && cluster.password != null)
    ])
    error_message = "Each Proxmox cluster must have either 'api_token' OR both 'username' and 'password' configured."
  }
}

variable "proxmox_ssh_key" {
  description = <<-EOT
    SSH private key for Proxmox authentication (CI/CD mode).

    Requirements:
    - Must be unencrypted (no passphrase)
    - Must be in PEM format (OpenSSH format)
    - Should be set as a Scalr environment variable (TF_VAR_proxmox_ssh_key)

    In Scalr, set this as an environment-level variable:
    Key: TF_VAR_proxmox_ssh_key
    Value: <paste SSH private key contents>
    Sensitive: Yes
  EOT
  type        = string
  sensitive   = true
  default     = null
}

# ============================================================================
# DigitalOcean Provider Configuration Variables
# ============================================================================

variable "digitalocean_token" {
  description = "DigitalOcean API token"
  type        = string
  sensitive   = true
  default     = null
}

variable "digitalocean_spaces_access_key" {
  description = "DigitalOcean Spaces access key ID"
  type        = string
  sensitive   = true
  default     = null
}

variable "digitalocean_spaces_secret_key" {
  description = "DigitalOcean Spaces secret access key"
  type        = string
  sensitive   = true
  default     = null
}

# ============================================================================
# Hetzner Provider Configuration Variables
# ============================================================================

variable "hetzner_token" {
  description = "Hetzner Cloud API token"
  type        = string
  sensitive   = true
  default     = null
}

# ============================================================================
# Infisical Provider Configuration Variables
# ============================================================================

variable "infisical_client_id" {
  description = "Infisical machine identity client ID"
  type        = string
  sensitive   = true
  default     = null
}

variable "infisical_client_secret" {
  description = "Infisical machine identity client secret"
  type        = string
  sensitive   = true
  default     = null
}

variable "infisical_host" {
  description = "Infisical API host URL"
  type        = string
  default     = "https://app.infisical.com"
}

# ============================================================================
# Agent Pool Configuration
# ============================================================================

variable "agent_pool_name" {
  description = "Name of the Scalr agent pool to use for self-hosted agent execution (optional)"
  type        = string
  default     = null
}

variable "agent_pool_environment" {
  description = "Environment name where the agent pool is defined (e.g., 'homelab'). Required if agent_pool_name is set."
  type        = string
  default     = null
}

# ============================================================================
# Data File Paths
# ============================================================================

variable "environments_data_path" {
  description = "Path to environment YAML configuration files"
  type        = string
  default     = "./data/environments"
}
