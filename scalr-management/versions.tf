terraform {
  required_version = ">= 1.8.0"

  required_providers {
    scalr = {
      source  = "registry.scalr.io/scalr/scalr"
      version = "3.12.0"
    }
  }
}
