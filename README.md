# terraform-aws-boundary

A Terraform module to deploy a Boundary cluster on AWS for testing and exploration.
It uses the latest release of
[HashiCorp Boundary](https://www.boundaryproject.io/) available for Linux.

It uses AWS KMS and disables TLS. For the exact configuration,
review the controller and worker configuration under
`templates/`.

**NOTE:** Use this module for testing purposes only!

## Requirements

| Name | Version |
|------|---------|
| terraform | >=1.0 |
| aws | >=3.63.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >=3.63.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| additional\_tags | List of tags for Boundary resources | `map(string)` | `{}` | no |
| allow\_cidr\_blocks\_to\_api | IP addresses to allow connection to Boundary API | `list(string)` | n/a | yes |
| allow\_cidr\_blocks\_to\_workers | IP addresses to allow connection to Boundary workers | `list(string)` | n/a | yes |
| boundary\_db\_password | Boundary database password | `string` | n/a | yes |
| boundary\_db\_username | Boundary database username | `string` | `"boundary"` | no |
| enable\_ssh\_to\_controller | Enable SSH rule to controller | `bool` | `false` | no |
| key\_pair\_name | Name of AWS key pair for SSH into Boundary instances | `string` | `null` | no |
| name | name of resources | `string` | n/a | yes |
| num\_controllers | Number of controller nodes | `number` | `1` | no |
| num\_workers | Number of worker nodes | `number` | `1` | no |
| private\_subnet\_ids | List of private subnet ids for Boundary database | `list(string)` | n/a | yes |
| public\_subnet\_ids | List of public subnet ids for Boundary | `list(string)` | n/a | yes |
| vpc\_cidr\_block | VPC CIDR block for Boundary cluster | `string` | n/a | yes |
| vpc\_id | VPC ID to deploy Boundary cluster | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| boundary\_controller | Boundary controller attributes |
| boundary\_lb | DNS name for Boundary load balancer |
| boundary\_security\_group | Security group for Boundary worker |
| kms\_recovery\_key\_id | AWS KMS ID for recovery |

