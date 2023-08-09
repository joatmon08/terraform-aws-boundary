resource "local_file" "outputs" {
  content  = <<EOT
name                         = "${var.name}"
region                       = "${var.region}"
vpc_id                       = "${module.vpc.vpc_id}"
vpc_cidr_block               = "${module.vpc.vpc_cidr_block}"
public_subnet_ids            = ${jsonencode(module.vpc.public_subnets)}
private_subnet_ids           = ${jsonencode(module.vpc.database_subnets)}
allow_cidr_blocks_to_api     = ["0.0.0.0/0"]
EOT
  filename = "../generated.tfvars"
}
