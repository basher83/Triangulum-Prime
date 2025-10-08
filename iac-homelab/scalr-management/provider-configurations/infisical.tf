terraform {
  required_providers {
    infisical = {
      version = "0.15.39"
      source = "infisical/infisical"
    }
  }
}

provider "infisical" {
  auth = {
    universal = {
      client_id     = var.machine-identity-client-id
      client_secret = var.machine-identity-client-secret
    }
  }
}
