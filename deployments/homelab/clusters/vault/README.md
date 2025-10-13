# Homelab Vault Cluster

**Scalr Workspace:** `homelab/vault-cluster`
**Execution Mode:** Remote (Scalr agent: bravo-143)
**Auto Apply:** No

## Purpose

This workspace manages a HashiCorp Vault cluster for centralized secrets management:

- Secure storage for secrets, certificates, and tokens
- Dynamic secrets generation
- Encryption as a service
- PKI and certificate management
- Integration with other homelab services

## Architecture

```
Vault Cluster (HA)
├── Node 1 (Leader)
├── Node 2 (Standby)
└── Node 3 (Standby)

Storage Backend
└── Integrated Raft Storage
```

## Workspace Variables

Configured in Scalr:

- `vault_version` = "1.15.0"
- `cluster_size` = "3"

## Post-Deployment

After cluster deployment:

1. Initialize Vault cluster
2. Unseal all nodes
3. Configure auto-unseal (optional)
4. Set up authentication methods
5. Create policies and roles
6. Enable secret engines
7. Configure audit logging

## Security Considerations

- Store unseal keys securely (consider using Shamir's Secret Sharing)
- Enable audit logging
- Use TLS for all communications
- Implement proper RBAC policies
- Regular backups of Raft storage
