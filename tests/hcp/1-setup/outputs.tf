output "boundary_worker_ssh" {
  value       = base64encode(tls_private_key.boundary.private_key_openssh)
  description = "Boundary worker SSH key"
  sensitive   = true
}

output "boundary_worker" {
  value       = module.boundary_worker.worker.public_ip
  description = "Boundary worker public IP"
}

output "boundary_addr" {
  value       = hcp_boundary_cluster.main.cluster_url
  description = "HCP Boundary cluster URL"
}

output "boundary_user" {
  value       = hcp_boundary_cluster.main.username
  description = "HCP Boundary cluster username"
}

output "boundary_password" {
  value       = hcp_boundary_cluster.main.password
  description = "HCP Boundary cluster password"
  sensitive   = true
}

output "vault_public_address" {
  value       = hcp_vault_cluster.main.vault_public_endpoint_url
  description = "HCP Vault cluster public URL"
}

output "vault_token" {
  value       = hcp_vault_cluster_admin_token.cluster.token
  description = "HCP Vault cluster token"
  sensitive   = true
}

output "vault_namespace" {
  value       = hcp_vault_cluster.main.namespace
  description = "HCP Vault cluster namespace"
}