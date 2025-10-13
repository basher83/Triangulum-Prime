# Homelab Kubernetes Cluster

**Scalr Workspace:** `homelab/k8s-cluster`
**Execution Mode:** Remote (Scalr agent: bravo-143)
**Auto Apply:** No

## Purpose

This workspace manages a Kubernetes cluster on Proxmox using MicroK8s:

- Control plane nodes (HA with 3 nodes recommended)
- Worker nodes for workload execution
- Cluster networking and storage
- Integration with homelab services

## Architecture

```
Control Plane (1-3 nodes)
├── API Server
├── etcd
└── Controller Manager

Workers (2+ nodes)
├── kubelet
├── Container Runtime
└── kube-proxy
```

## Workspace Variables

Configured in Scalr:

- `cluster_size` = "3"
- `control_plane_count` = "1"
- `worker_count` = "2"

## Post-Deployment

After cluster creation:

1. Configure kubectl access
2. Install CNI plugin (Calico/Flannel)
3. Configure persistent storage
4. Install ingress controller
5. Set up monitoring
