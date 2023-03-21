terraform {
  required_version = ">=1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=4.32.0,<5.0"
    }
  }
}