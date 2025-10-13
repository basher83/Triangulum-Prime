# Homelab Nomad + Consul Cluster

**Scalr Workspace:** `homelab/nomad-consul-cluster`
**Execution Mode:** Remote (Scalr agent: bravo-143)
**Auto Apply:** No

## Purpose

This workspace manages an integrated HashiCorp Nomad and Consul cluster:

- **Nomad**: Workload orchestration and scheduling
- **Consul**: Service discovery, service mesh, and KV store

## Architecture

```
Server Nodes (3)
├── Nomad Server (leader election)
└── Consul Server (consensus)

Client Nodes (3+)
├── Nomad Client (workload execution)
└── Consul Agent (service registration)
```

## Workspace Variables

Configured in Scalr:

- `nomad_version` = "1.7.0"
- `consul_version` = "1.17.0"
- `server_count` = "3"
- `client_count` = "3"

## Workload Types

Nomad supports multiple workload types:

- Docker containers
- QEMU virtual machines
- Java applications
- Raw exec binaries
- LXC containers

## Post-Deployment

After cluster deployment:

1. Bootstrap Consul ACL system
2. Bootstrap Nomad ACL system
3. Configure Consul Connect (service mesh)
4. Set up Nomad job templates
5. Configure Vault integration
6. Set up monitoring (Prometheus/Grafana)
7. Deploy sample workloads

## Integration

- **Vault**: Dynamic secrets and PKI
- **Consul**: Service discovery and configuration
- **Prometheus**: Metrics and monitoring
- **Traefik**: Ingress and load balancing
