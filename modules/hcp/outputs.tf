output "worker" {
  value       = aws_instance.worker
  description = "Information about Boundary worker"
}

output "security_group" {
  value       = aws_security_group.worker
  description = "Security group for worker"
}