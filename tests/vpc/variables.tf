variable "name" {
  type        = string
  description = "Name of the resources"
  default     = "test-terraform-aws-boundary"
}

variable "region" {
  type        = string
  description = "AWS Region"
  default     = "us-east-2"
}

variable "vpc_cidr_block" {
  type        = string
  default     = "10.0.0.0/16"
  description = "CIDR Block for VPC"
}

variable "tags" {
  type        = map(any)
  description = "Tags to add resources"
  default = {
    Test = "terraform-aws-boundary"
  }
}