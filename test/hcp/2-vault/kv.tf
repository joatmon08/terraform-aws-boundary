resource "vault_mount" "boundary_worker" {
  path        = "boundary/worker"
  type        = "kv"
  options     = { version = "2" }
  description = "Boundary worker tokens"
}

output "boundary_worker_path" {
  value = vault_mount.boundary_worker.path
}
