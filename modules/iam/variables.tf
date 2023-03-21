variable "name" {
  description = "Name of worker and associated resources"
  type        = string
}


variable "tags" {
  description = "Tags for AWS IAM role"
  type        = map(string)
}