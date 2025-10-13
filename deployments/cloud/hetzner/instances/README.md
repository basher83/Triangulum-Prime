# Hetzner Cloud Instances

**Scalr Workspace:** `cloud/hetzner-instances`
**Execution Mode:** Remote (Scalr managed agents)
**Auto Apply:** No (disabled until production-ready)

## Purpose

Cost-effective cloud compute with Hetzner:

- Development/testing environments
- CI/CD runners
- Application servers
- Database servers

## Workspace Variables

- `location` = "nbg1" (Nuremberg, Germany)
- `server_type` = "cx11"
- `instance_count` = "1"

## Locations

- **Germany**: nbg1 (Nuremberg), fsn1 (Falkenstein), hel1 (Helsinki)
- **Finland**: hel1
- **US**: ash (Ashburn)

## Server Types

- **CX**: Shared vCPU - cx11, cx21, cx31, cx41, cx51
- **CPX**: Dedicated vCPU - cpx11, cpx21, cpx31, cpx41, cpx51
- **CCX**: Dedicated AMD - ccx13, ccx23, ccx33, ccx43, ccx53

## Pricing Advantages

Hetzner offers excellent price/performance:

- cx11: €3.79/month (2 GB RAM, 1 vCPU)
- cx21: €5.99/month (4 GB RAM, 2 vCPU)
- cx31: €11.99/month (8 GB RAM, 2 vCPU)
