terraform {
  required_version = "~> 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.32"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.4"
    }
    hcp = {
      source  = "hashicorp/hcp"
      version = "~> 0.45"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = var.tags
  }
}

provider "hcp" {}