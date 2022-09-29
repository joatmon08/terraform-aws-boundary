variable "name" {
  type        = string
  description = "Name of the resources"
  default     = "test-terraform-aws-boundary"
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

variable "key_pair_name" {
  type        = string
  description = "SSH keypair name for Boundary and EKS nodes"
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
    Test = "terraform-aws-boundary"
  }
}