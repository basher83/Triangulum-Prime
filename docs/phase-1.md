# Phase 1: Foundation Setup (Week 1-2)

**1.1 Repository Initialization**
- Create the base directory structure
- Initialize git repository with proper .gitignore
- Set up OpenTofu version constraints
- Create basic documentation

**1.2 Module Development**
- Develop Proxmox VM module for single instances
- Create Proxmox LXC module
- Build basic cloud provider modules (DigitalOcean, Hetzner)
- Implement cluster modules for Vault, Nomad, K8s

**1.3 Local Testing Infrastructure**
- Set up local backend configurations for testing
- Create test workspaces for each deployment type
- Implement basic validation and testing scripts

# Scalr Private Module Registry:
[Overview](https://docs.scalr.io/docs/private-module-registry#overview)

When adding modules to Scalr, they can be used in two different ways:

- Library module - Boilerplate code with the internal source reference that can be used to call the module from any Terraform or OpenTofu configuration in a Scalr environment.

- Deployable module - The same as a library module, but can be deployed through the module registry UI to create a no-code workspace.

The module registry also provides version control for modules. Modules can only be registered if Git releases or tagged versions have been created in the repository. Module calls via the registry must use versions, thus new versions can be released without impacting existing deployments.

Here is an example module call from the registry:

```hcl
module "instance" {
  source  = "my-account.scalr.io/namespace/instance/aws"
  version = "1.0.1"
  instance_type = var.instance_type
  instance_count = var.instance_count
  subnet = var.subnet
  sg = var.security_group
  key = var.ssh_key
  vpc_id = var.vpc_id
  ami = var.ami
}
```

*Note*:
A git release is a tagged version of the code. Once created a release never changes as it is pinned to a specific commit. Tags must use semantic version numbering (m.m.p, e.g v1.0.4, 0.7.3) and can be created via the CLI (see git tag) or in the git VCS console via the “releases” page.

Modules in the registry are automatically pulled into workspaces where they are called and the registration process automatically creates internal references to the module to be used in the Terraform configuration.

Alternatively, it is possible to use external registries, such as those stored in Git, and use SSH keys to pull the modules into the run as needed.

## Namespaces

Modules must be published into a module namespace at the Scalr account scope. The namespace is how you can organize your modules, assign ownership, and share them with environments or the entire account.

The following permissions apply to module namespaces:

Action	Required Permission
Read account-level modules	module-namespaces:read and modules:read
Read env-shared modules	environments:read and modules:read
Update or resync a module	module-namespaces:update and modules:update
Delete a module	module-namespaces:update and modules:delete

## Publishing Modules
Before publishing a module, you must select which namespace to publish it in.

Scalr supports a module per repo or sub-modules (aka mono repo). In both cases, the modules use semantic versioning from the VCS repository. In a module per repo, it pulls the versions for the entire repo, in the sub-module use case, Scalr will reference tag prefixes so each individual module can have its own versioning.

## Sub-Modules (Mono Repo)
For modules in a mono repo, the repository itself can have any name, but the sub-folders for each module must use the format terraform-<provider_name>-<module_name>, e.g. terraform-aws-instance