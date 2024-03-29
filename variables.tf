locals {
  tags = merge(var.additional_tags, {
    Name    = "${var.name}-boundary",
    Module  = "terraform-aws-boundary",
    Purpose = "boundary"
  })
}

variable "vpc_id" {
  description = "VPC ID to deploy Boundary cluster"
  type        = string
}

variable "vpc_cidr_block" {
  description = "VPC CIDR block for Boundary cluster"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet ids for Boundary"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet ids for Boundary database"
  type        = list(string)
}

variable "name" {
  description = "name of resources"
  type        = string
}

variable "key_pair_name" {
  type        = string
  description = "Name of AWS key pair for SSH into Boundary instances"
  default     = null
}

variable "num_workers" {
  type        = number
  default     = 1
  description = "Number of worker nodes"
}

variable "num_controllers" {
  type        = number
  default     = 1
  description = "Number of controller nodes"
}

variable "allow_cidr_blocks_to_api" {
  description = "IP addresses to allow connection to Boundary API"
  type        = list(string)
}

variable "allow_cidr_blocks_to_workers" {
  description = "IP addresses to allow connection to Boundary workers"
  type        = list(string)
}

variable "enable_ssh_to_controller" {
  description = "Enable SSH rule to controller"
  type        = bool
  default     = false
}

variable "additional_tags" {
  description = "List of tags for Boundary resources"
  default     = {}
  type        = map(string)
}

variable "boundary_db_username" {
  description = "Boundary database username"
  default     = "boundary"
  type        = string
}

variable "boundary_db_password" {
  description = "Boundary database password"
  type        = string
  sensitive   = true
}

variable "boundary_sink_file_path" {
  description = "File path for Boundary events sink"
  type        = string
  default     = "/var/log/boundary"
}

variable "boundary_sink_file_name" {
  description = "File name for Boundary events sink"
  type        = string
  default     = "audit.log"
}

variable "datadog_api_key" {
  description = "Datadog API Key for audit logging"
  type        = string
  sensitive   = true
  default     = null
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}