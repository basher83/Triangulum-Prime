# DigitalOcean Spaces

**Scalr Workspace:** `cloud/digitalocean-spaces`
**Execution Mode:** Remote (Scalr managed agents)
**Auto Apply:** No

## Purpose

This workspace manages DigitalOcean Spaces (S3-compatible object storage):

- Homelab backups (Proxmox, VMs, configs)
- Media and asset storage
- Static website hosting
- Terraform state backends
- Log archival

## Workspace Variables

Configured in Scalr:

- `region` = "nyc3"

## Available Regions

- **NYC**: nyc3
- **SFO**: sfo2, sfo3
- **AMS**: ams3
- **SGP**: sgp1

## Features

### Versioning

Enable versioning for backup protection:

```hcl
versioning {
  enabled = true
}
```

### Lifecycle Policies

Automatically delete old versions:

```hcl
lifecycle_rule {
  expiration {
    days = 90
  }
}
```

### CDN

Enable CDN for faster content delivery:

```hcl
resource "digitalocean_cdn" "example" {
  origin = digitalocean_spaces_bucket.example.bucket_domain_name
}
```

## Use Cases

- **Backup Storage**: Proxmox backups, database dumps
- **Static Sites**: Host static websites with CDN
- **Media Storage**: Images, videos, documents
- **State Backend**: Remote state for other Terraform projects
- **Log Archive**: Long-term log storage

## S3 Compatibility

Spaces is S3-compatible, use with:

- AWS CLI: `aws s3 --endpoint=https://nyc3.digitaloceanspaces.com`
- rclone, s3cmd, boto3, and other S3 tools
