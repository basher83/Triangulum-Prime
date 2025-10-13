# DigitalOcean Droplets

**Scalr Workspace:** `cloud/digitalocean-droplets`
**Execution Mode:** Remote (Scalr managed agents)
**Auto Apply:** No (disabled until production-ready)

## Purpose

This workspace manages DigitalOcean droplets for cloud-based workloads:

- Development and testing environments
- CI/CD runners
- Jump/bastion hosts
- Temporary compute resources
- Public-facing services

## Workspace Variables

Configured in Scalr:

- `region` = "nyc3"
- `droplet_size` = "s-1vcpu-1gb"
- `droplet_count` = "2"

## Available Regions

- **NYC**: nyc1, nyc3
- **SFO**: sfo2, sfo3
- **AMS**: ams3
- **SGP**: sgp1
- **LON**: lon1
- **FRA**: fra1
- **TOR**: tor1
- **BLR**: blr1

## Droplet Sizes

- **Basic**: s-1vcpu-1gb, s-1vcpu-2gb, s-2vcpu-2gb, s-2vcpu-4gb
- **General Purpose**: g-2vcpu-8gb, g-4vcpu-16gb
- **CPU-Optimized**: c-2, c-4, c-8
- **Memory-Optimized**: m-2vcpu-16gb, m-4vcpu-32gb

## Deployment

Changes pushed to the `main` branch will trigger a Scalr plan. Review the plan in the Scalr UI and manually apply when ready. Auto-apply is disabled for safety until your infrastructure is production-ready.
