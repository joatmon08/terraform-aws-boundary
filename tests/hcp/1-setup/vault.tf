resource "hcp_hvn" "main" {
  hvn_id         = var.name
  cloud_provider = "aws"
  region         = var.region
  cidr_block     = var.hcp_cidr_block
}

resource "hcp_vault_cluster" "main" {
  cluster_id      = var.name
  hvn_id          = hcp_hvn.main.hvn_id
  public_endpoint = true
  tier            = "dev"
}

resource "hcp_vault_cluster_admin_token" "cluster" {
  cluster_id = hcp_vault_cluster.main.cluster_id
}