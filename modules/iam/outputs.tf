output "iam_role" {
  value       = aws_iam_role.boundary
  description = "AWS IAM Role for Boundary"
}

output "iam_instance_profile" {
  value       = aws_iam_instance_profile.boundary
  description = "AWS IAM Instance Profile for Boundary"
}