variable "name" {
  type        = string
  description = "Name of the resources"
  default     = "test-terraform-aws-hcp-boundary"
}

variable "region" {
  type        = string
  description = "AWS Region"
}

variable "vpc_cidr_block" {
  type        = string
  default     = "10.0.0.0/16"
  description = "CIDR Block for VPC"
}

variable "hcp_cidr_block" {
  type        = string
  default     = "172.25.16.0/20"
  description = "CIDR block of the HashiCorp Virtual Network"
}

variable "client_cidr_block" {
  type        = list(string)
  description = "Client CIDR block"
  sensitive   = true
}

variable "tags" {
  type        = map(any)
  description = "Tags to add resources"
  default = {
    Test = "terraform-aws-hcp-boundary"
  }
}