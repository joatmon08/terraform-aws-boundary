data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = [
    "099720109477"
  ]
}

module "iam" {
  source = "../iam"
  name   = var.name
  tags   = var.tags
}

resource "boundary_worker" "worker" {
  scope_id    = var.boundary_scope_id
  name        = var.name
  description = "Self-managed worker using controller-led registration"
}

resource "aws_instance" "worker" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  iam_instance_profile        = module.iam.iam_instance_profile.name
  subnet_id                   = var.public_subnet_id
  key_name                    = var.key_pair_name
  vpc_security_group_ids      = [var.worker_security_group_id != null ? var.worker_security_group_id : aws_security_group.worker.0.id]
  associate_public_ip_address = true

  user_data = templatefile("${path.module}/templates/user_data_worker.tmpl.sh", {
    boundary_cluster_id                   = var.boundary_cluster_id
    initial_upstreams                     = jsonencode(var.worker_upstreams)
    worker_tags                           = jsonencode(var.worker_tags)
    controller_generated_activation_token = boundary_worker.worker.controller_generated_activation_token
  })

  tags = merge(var.tags, {
    Name = "${var.name}-boundary-worker"
  })
}

resource "aws_security_group" "worker" {
  count  = var.worker_security_group_id == null ? 1 : 0
  vpc_id = var.vpc_id

  tags = var.tags
}

resource "aws_security_group_rule" "allow_9202_worker" {
  type              = "ingress"
  from_port         = 9202
  to_port           = 9202
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = var.worker_security_group_id != null ? var.worker_security_group_id : aws_security_group.worker.0.id
}

resource "aws_security_group_rule" "allow_egress_worker" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = var.worker_security_group_id != null ? var.worker_security_group_id : aws_security_group.worker.0.id
}
