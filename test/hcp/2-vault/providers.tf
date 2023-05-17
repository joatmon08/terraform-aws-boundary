terraform {
  required_providers {
    vault = {
      source = "hashicorp/vault"
      version = "~> 3.15"
    }
  }
}

data "terraform_remote_state" "setup" {
  backend = "local"

  config = {
    path = "../1-setup"
  }
}

provider "vault" {
  address = data.terraform_remote_state.setup.outputs.vault_public_address
  namespace = data.terraform_remote_state.setup.outputs.vault_namespace
  token = data.terraform_remote_state.setup.outputs.vault_token
}