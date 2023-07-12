variable "name" {
  description = "Name of worker and associated resources"
  type        = string
}

variable "boundary_cluster_id" {
  description = "HCP Boundary Cluster ID"
  type        = string
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

variable "vault_addr" {
  description = "Vault address for worker to write authentication token"
  type        = string
  default     = null
}

variable "vault_namespace" {
  description = "Vault namespace for worker to write authentication token. For ENT or HCP"
  type        = string
  default     = "admin"
}

variable "vault_path" {
  description = "Vault path for worker to write authentication token"
  type        = string
  default     = "/boundary"
}

variable "vault_token" {
  description = "Vault token for worker to write authentication token"
  type        = string
  sensitive   = true
}

variable "worker_security_group_id" {
  description = "Boundary worker security group ID. If null, module will create it"
  type        = string
  default     = null
}