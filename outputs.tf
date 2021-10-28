output "boundary_lb" {
  value       = aws_lb.controller.dns_name
  description = "DNS name for Boundary load balancer"
}

output "kms_recovery_key_id" {
  value       = aws_kms_key.recovery.id
  description = "AWS KMS ID for recovery"
}

output "boundary_controller" {
  value       = aws_instance.controller
  description = "Boundary controller attributes"
}

output "boundary_security_group" {
  value       = aws_security_group.worker.id
  description = "Security group for Boundary worker"
}