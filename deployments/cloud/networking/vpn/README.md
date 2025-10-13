# Multi-Cloud VPN

**Scalr Workspace:** `cloud/multi-cloud-vpn`
**Execution Mode:** Remote (Scalr managed agents)
**Auto Apply:** No

## Purpose

Establish site-to-site VPN connections between:

- **Homelab** (on-premise Proxmox)
- **DigitalOcean** (cloud resources)
- **Hetzner Cloud** (cloud resources)

## Architecture

```
Homelab (192.168.x.x/16)
    |
    | WireGuard VPN
    |
    +-- DigitalOcean (10.10.x.x/16)
    |
    +-- Hetzner Cloud (10.20.x.x/16)
```

## Workspace Variables

Configured in Scalr:

- `homelab_public_ip` = "0.0.0.0" (sensitive, update with actual IP)

## VPN Options

### WireGuard (Recommended)

- Modern, fast, and secure
- Easy to configure
- Great performance
- Cross-platform support

### IPsec/IKEv2

- Traditional enterprise VPN
- Built into most firewalls
- More complex configuration

### OpenVPN

- Mature and well-tested
- More overhead than WireGuard
- Better firewall traversal

## Use Cases

1. **Hybrid Cloud**: Run workloads across homelab and cloud
2. **Backup/DR**: Backup homelab to cloud storage
3. **Development**: Access homelab services from cloud
4. **Migration**: Migrate workloads between environments
5. **Monitoring**: Centralized monitoring across all infrastructure

## Security Considerations

- Use strong authentication (public key)
- Enable firewall rules
- Rotate keys regularly
- Monitor VPN logs
- Use split-tunnel when appropriate

## Post-Deployment

After VPN setup:

1. Test connectivity both ways
2. Configure routing tables
3. Set up firewall rules
4. Test failover scenarios
5. Document IP allocations
6. Set up monitoring
