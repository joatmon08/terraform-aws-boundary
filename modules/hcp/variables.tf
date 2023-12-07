variable "name" {
  description = "Name of worker and associated resources"
  type        = string
}

variable "boundary_cluster_id" {
  description = "HCP Boundary Cluster ID"
  type        = string
}

variable "controller_generated_activation_token" {
  description = "Boundary controller-generated activation token for worker"
  type        = string
  sensitive   = true
}

variable "boundary_scope_id" {
  description = "Boundary scope ID for worker, defaults to global"
  type        = string
  default     = null
}

variable "worker_upstreams" {
  description = "A list of workers to connect to upstream. For multi-hop worker sessions. Format should be [\"<upstream_worker_public_addr>:9202\"]"
  type        = list(string)
  default     = []
}

variable "worker_tags" {
  description = "A list of worker tags for filtering in Boundary"
  type        = list(string)
  default     = []
}

variable "vpc_id" {
  description = "VPC ID for security group"
  type        = string
}

variable "tags" {
  description = "Tags for associated resources"
  type        = map(string)
  default     = {}
}

variable "key_pair_name" {
  description = "AWS Key pair for SSH access"
  type        = string
}

variable "public_subnet_id" {
  description = "Public Subnet ID for instance"
  type        = string
}

variable "worker_security_group_id" {
  description = "Boundary worker security group ID. If null, module will create it"
  type        = string
  default     = null
}

