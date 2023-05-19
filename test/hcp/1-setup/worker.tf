resource "aws_key_pair" "boundary" {
  key_name   = var.name
  public_key = trimspace(tls_private_key.boundary.public_key_openssh)
}

resource "tls_private_key" "boundary" {
  algorithm = "RSA"
}

module "boundary_worker" {
  depends_on          = [module.vpc]
  source              = "../../modules/hcp"
  name                = var.name
  boundary_cluster_id = split(".", replace(hcp_boundary_cluster.main.cluster_url, "https://", "", ))[0]
  worker_tags         = [var.name, "ingress"]
  vpc_id              = module.vpc.vpc_id
  key_pair_name       = aws_key_pair.boundary.key_name
  public_subnet_id    = module.vpc.public_subnets.0
  vault_addr          = hcp_vault_cluster.main.vault_public_endpoint_url
  vault_namespace     = hcp_vault_cluster.main.namespace
  vault_token         = hcp_vault_cluster_admin_token.cluster.token
  vault_path          = "boundary/worker"
}

resource "aws_security_group_rule" "allow_9202_worker" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = var.client_cidr_block
  security_group_id = module.boundary_worker.security_group.id
}