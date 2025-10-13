# Cloud Deployments

This directory contains cloud provider resources managed through Scalr.

## Directory Structure

```
cloud/
├── digitalocean/
│   ├── droplets/        # Compute instances
│   └── spaces/          # Object storage (S3-compatible)
├── hetzner/
│   ├── instances/       # Cloud servers
│   └── networking/      # Private networks and load balancers
└── networking/
    └── vpn/             # Multi-cloud VPN (WireGuard/IPsec)
```

## Cloud Providers

### DigitalOcean

- **Droplets**: $4-$960/month
- **Spaces**: $5/month (250 GB storage, 1 TB transfer)
- **Regions**: NYC, SFO, AMS, SGP, LON, FRA, TOR, BLR

### Hetzner Cloud

- **Servers**: €3.79-€289/month
- **Private Networks**: Free
- **Load Balancers**: €5.89-€29.90/month
- **Regions**: Germany, Finland, US

## Scalr Workspaces

| Workspace | Directory | Auto-Apply | Purpose |
|-----------|-----------|------------|---------|
| `digitalocean-droplets` | `digitalocean/droplets` | Yes | Compute instances |
| `digitalocean-spaces` | `digitalocean/spaces` | No | Object storage |
| `hetzner-instances` | `hetzner/instances` | Yes | Cloud servers |
| `hetzner-networking` | `hetzner/networking` | No | VPC and load balancers |
| `multi-cloud-vpn` | `networking/vpn` | No | Site-to-site VPN |

## Execution

- **Agent**: Scalr-managed (public cloud)
- **Platform**: OpenTofu 1.10.0+
- **VCS**: GitHub (basher83/triangulum-prime)
- **Branch**: main

## Cost Management

### DigitalOcean

```
Typical monthly costs:
├── Droplet (s-1vcpu-1gb): $6
├── Spaces: $5 (250 GB)
└── Bandwidth: $0.01/GB
```

### Hetzner

```
Typical monthly costs:
├── CX11 (1 vCPU, 2 GB): €3.79
├── CX21 (2 vCPU, 4 GB): €5.99
├── Load Balancer (LB11): €5.89
└── Traffic: Free (20 TB+)
```

## Use Cases

### Development/Testing

- Spin up temporary environments
- CI/CD runners
- Integration testing

### Hybrid Cloud

- Extend homelab capacity
- Geographic distribution
- Disaster recovery

### Public Services

- Web applications
- APIs
- Static websites

## Networking Architecture

```
Homelab (192.168.x.x/16)
    |
    | WireGuard VPN
    |
    +-- DigitalOcean VPC (10.10.x.x/16)
    |       |
    |       +-- Droplets
    |       +-- Load Balancers
    |
    +-- Hetzner Private Network (10.20.x.x/16)
            |
            +-- Cloud Servers
            +-- Load Balancers
```

## Provider Configuration

Managed by Scalr provider configurations:

```hcl
# DigitalOcean
provider "digitalocean" {
  # token, spaces_access_key, spaces_secret_key
  # provided by Scalr
}

# Hetzner
provider "hcloud" {
  # token provided by Scalr
}
```

## Common Patterns

### Auto-Scaling Droplet

```hcl
resource "digitalocean_droplet" "web" {
  count  = var.instance_count
  name   = "web-${count.index + 1}"
  image  = "ubuntu-22-04-x64"
  region = "nyc3"
  size   = "s-2vcpu-2gb"

  tags = ["production", "web"]
}
```

### Hetzner with Private Network

```hcl
resource "hcloud_server" "app" {
  name        = "app-server"
  server_type = "cx21"
  location    = "nbg1"
  image       = "ubuntu-22.04"

  network {
    network_id = hcloud_network.private.id
  }
}
```

### Spaces Backup

```hcl
resource "digitalocean_spaces_bucket" "backup" {
  name   = "homelab-backups"
  region = "nyc3"
  acl    = "private"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    expiration {
      days = 90
    }
  }
}
```

## Security

### SSH Keys

```hcl
resource "digitalocean_ssh_key" "default" {
  name       = "homelab-key"
  public_key = file("~/.ssh/id_ed25519.pub")
}

resource "digitalocean_droplet" "web" {
  ssh_keys = [digitalocean_ssh_key.default.id]
  # ...
}
```

### Firewalls

```hcl
resource "digitalocean_firewall" "web" {
  name = "web-firewall"

  droplet_ids = digitalocean_droplet.web[*].id

  inbound_rule {
    protocol         = "tcp"
    port_range       = "80"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "443"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = [var.homelab_ip]
  }
}
```

## Monitoring

- **Uptime**: DigitalOcean/Hetzner dashboards
- **Metrics**: Prometheus exporters
- **Logs**: Centralized logging to homelab
- **Alerts**: Alertmanager integration

## Cost Optimization

1. **Right-size**: Start small, scale as needed
2. **Reserved instances**: Hetzner doesn't charge for stopped servers
3. **Snapshots**: Delete old snapshots
4. **Bandwidth**: Hetzner includes generous free traffic
5. **Storage**: Use Spaces lifecycle rules

## Disaster Recovery

1. **Snapshots**: Regular automated snapshots
2. **Spaces backups**: Off-site in different region
3. **Infrastructure as Code**: This repository
4. **VPN**: Quick access from homelab
5. **Documentation**: Runbooks for recovery

## Migration Path

From homelab to cloud (or vice versa):

1. Set up VPN connection
2. Replicate data via VPN
3. Test services in cloud
4. Update DNS
5. Decommission old resources

## Troubleshooting

### API Rate Limits

Both providers have rate limits. Scalr handles retries automatically.

### Region Unavailability

If a region is unavailable:

```hcl
variable "fallback_regions" {
  default = ["nyc3", "nyc1", "sfo3"]
}
```

### VPN Connection Issues

Check:
- Firewall rules
- Public IP changes
- WireGuard config
- Routing tables
