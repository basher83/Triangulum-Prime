# Proxmox SSH Key Setup for Scalr CI/CD

## Overview

VM template creation requires SSH access to Proxmox hosts for image import operations. When running in Scalr's CI/CD environment (remote agent), you must provide an SSH private key since SSH agent forwarding is not available.

## Requirements

The SSH private key must:
- ✅ Be unencrypted (no passphrase)
- ✅ Be in PEM format (OpenSSH format)
- ✅ Have access to all three Proxmox clusters (foxtrot, bravo, lloyd)
- ✅ Be stored securely in Scalr as a sensitive variable

## Step 1: Generate SSH Key (if needed)

If you don't already have a suitable SSH key:

```bash
# Generate new SSH key WITHOUT passphrase
ssh-keygen -t ed25519 -f ~/.ssh/proxmox_scalr -N "" -C "scalr-terraform"

# This creates:
# ~/.ssh/proxmox_scalr (private key)
# ~/.ssh/proxmox_scalr.pub (public key)
```

## Step 2: Add Public Key to Proxmox Hosts

Copy the public key to **all three** Proxmox nodes:

```bash
# For each cluster node:
ssh-copy-id -i ~/.ssh/proxmox_scalr.pub terraform@192.168.30.30  # bravo (nexus)
ssh-copy-id -i ~/.ssh/proxmox_scalr.pub terraform@192.168.10.2   # lloyd (quantum)
ssh-copy-id -i ~/.ssh/proxmox_scalr.pub terraform@192.168.3.5    # foxtrot (matrix)
```

Or manually add to each node:

```bash
# On each Proxmox host, as the terraform user:
mkdir -p ~/.ssh
chmod 700 ~/.ssh
cat >> ~/.ssh/authorized_keys << 'EOF'
<paste contents of proxmox_scalr.pub here>
EOF
chmod 600 ~/.ssh/authorized_keys
```

## Step 3: Test SSH Access

Verify connectivity from your local machine:

```bash
ssh -i ~/.ssh/proxmox_scalr terraform@192.168.30.30 "hostname"  # Should return: bravo
ssh -i ~/.ssh/proxmox_scalr terraform@192.168.10.2 "hostname"   # Should return: lloyd
ssh -i ~/.ssh/proxmox_scalr terraform@192.168.3.5 "hostname"    # Should return: foxtrot
```

## Step 4: Add SSH Key to Scalr

### Option A: Environment-Level Variable (Recommended)

Set at the **homelab environment** level so all workspaces can use it:

1. Navigate to Scalr UI → **Environments** → **homelab**
2. Go to **Variables** tab
3. Click **Add Variable**
4. Configure:
   - **Key**: `TF_VAR_proxmox_ssh_key`
   - **Value**: Copy entire contents of `~/.ssh/proxmox_scalr` file
   - **Category**: Shell
   - **Sensitive**: ✅ Yes (check this!)
   - **Description**: "SSH private key for Proxmox CI/CD authentication"
5. Click **Save**

### Option B: Workspace-Level Variable

Set individually for each template workspace (vm-templates-matrix, vm-templates-nexus, vm-templates-quantum):

1. Navigate to Scalr UI → **Workspaces** → Select workspace
2. Go to **Variables** tab
3. Add variable as described in Option A

**Note:** Environment-level is more efficient since all three template workspaces need the same key.

## Step 5: Update Scalr Management Configuration

Already done! The `terraform.auto.tfvars` has been updated to use:

```hcl
proxmox_clusters = {
  "nexus" = {
    endpoint        = "https://192.168.30.30:8006"
    api_token       = "..."
    ssh_agent       = false
    ssh_private_key = var.proxmox_ssh_key  # References Scalr variable
  }
  # ... same for quantum and matrix
}
```

## Step 6: Apply Changes to Scalr

```bash
cd scalr-management

# Set the SSH key locally for testing
export TF_VAR_proxmox_ssh_key="$(cat ~/.ssh/proxmox_scalr)"

# Test the plan
tofu plan

# Apply to update Scalr provider configurations
tofu apply
```

## Step 7: Test in Scalr

Queue a plan in one of the template workspaces (e.g., `vm-templates-nexus`) to verify:

1. Scalr can authenticate to Proxmox API ✅
2. Scalr can SSH to Proxmox host ✅
3. Template creation succeeds ✅

## Security Notes

### ✅ DO
- Store SSH key as **sensitive** variable in Scalr
- Use environment-level variable for efficiency
- Generate a dedicated key for Scalr (not your personal SSH key)
- Rotate keys periodically
- Use unencrypted keys (agent not available in CI/CD)

### ❌ DON'T
- Commit SSH private keys to git
- Use your personal SSH key
- Store in plain text files
- Share keys between environments (prod vs dev)

## Troubleshooting

### "Permission denied (publickey)"

**Cause:** SSH key not authorized on Proxmox host

**Fix:**
```bash
# Verify public key is in authorized_keys on Proxmox
ssh terraform@192.168.30.30 "cat ~/.ssh/authorized_keys"
```

### "Bad decrypt: ssh: cannot decode encrypted private keys"

**Cause:** SSH key has a passphrase

**Fix:**
```bash
# Remove passphrase from existing key
ssh-keygen -p -f ~/.ssh/proxmox_scalr -N ""
```

### "Connection refused" or "No route to host"

**Cause:** Network connectivity issue

**Fix:**
- Verify Scalr agent (bravo-143) can reach Proxmox hosts
- Check firewall rules on Proxmox hosts
- Verify SSH daemon is running: `systemctl status sshd`

## Local Development vs CI/CD

For **local development**, you can use `ssh_agent = true`:

```hcl
proxmox_clusters = {
  "nexus" = {
    endpoint  = "https://192.168.30.30:8006"
    api_token = "..."
    ssh_agent = true  # Uses local SSH agent
  }
}
```

For **Scalr/CI/CD**, use `ssh_private_key`:

```hcl
proxmox_clusters = {
  "nexus" = {
    endpoint        = "https://192.168.30.30:8006"
    api_token       = "..."
    ssh_agent       = false
    ssh_private_key = var.proxmox_ssh_key
  }
}
```

## References

- [Proxmox Provider SSH Configuration](https://registry.terraform.io/providers/bpg/proxmox/latest/docs#ssh-connection)
- [Scalr Environment Variables](https://docs.scalr.com/en/latest/variables.html)
