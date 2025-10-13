# Hetzner Cloud Networking

**Scalr Workspace:** `cloud/hetzner-networking`
**Execution Mode:** Remote (Scalr managed agents)
**Auto Apply:** No

## Purpose

Manage Hetzner Cloud networking resources:

- Private networks (VPC)
- Network subnets
- Load balancers
- Firewalls
- Floating IPs

## Features

### Private Networks

Create isolated networks for your servers:

```hcl
resource "hcloud_network" "private" {
  name     = "app-network"
  ip_range = "10.0.0.0/16"
}
```

### Load Balancers

Distribute traffic across multiple servers:

- **lb11**: €5.89/month (20k connections, 20 Mbps)
- **lb21**: €13.90/month (40k connections, 40 Mbps)
- **lb31**: €29.90/month (100k connections, 100 Mbps)

### Network Zones

- **eu-central**: Germany, Finland
- **us-east**: US East
- **us-west**: US West (planned)
