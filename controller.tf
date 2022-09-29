resource "aws_instance" "controller" {
  count                       = var.num_controllers
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  iam_instance_profile        = aws_iam_instance_profile.boundary.name
  subnet_id                   = var.public_subnet_ids[count.index]
  key_name                    = var.key_pair_name
  vpc_security_group_ids      = [aws_security_group.controller.id]
  associate_public_ip_address = true

  ebs_block_device {
    delete_on_termination = true
    device_name           = "/dev/sdf"
    encrypted             = false

    tags = merge(local.tags, {
      Name      = "${var.name}-boundary-controller",
      Component = "controller"
      Purpose   = "boundary-audit-logs"
    })

    volume_size = 32
    volume_type = "gp2"
  }


  user_data = templatefile("${path.module}/templates/user_data_controller.tmpl.sh", {
    name                    = var.name
    index                   = count.index
    db_username             = var.boundary_db_username
    db_password             = var.boundary_db_password
    db_endpoint             = aws_db_instance.boundary.endpoint
    kms_worker_auth_key_id  = aws_kms_key.worker_auth.id
    kms_recovery_key_id     = aws_kms_key.recovery.id
    kms_root_key_id         = aws_kms_key.root.id
    boundary_sink_file_path = var.boundary_sink_file_path
    boundary_sink_file_name = var.boundary_sink_file_name
    datadog_api_key         = var.datadog_api_key
  })

  tags = merge(local.tags, {
    Name      = "${var.name}-boundary-controller",
    Component = "controller"
  })
}

resource "aws_security_group" "controller" {
  vpc_id = var.vpc_id

  tags = merge(local.tags, {
    Name      = "${var.name}-boundary-controller",
    Component = "controller"
  })
}

# Boundary API
resource "aws_security_group_rule" "allow_9200_controller" {
  type                     = "ingress"
  from_port                = 9200
  to_port                  = 9200
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.controller_lb.id
  security_group_id        = aws_security_group.controller.id
}

resource "aws_security_group_rule" "allow_9201_controller" {
  type              = "ingress"
  from_port         = 9201
  to_port           = 9201
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_cidr_block]
  security_group_id = aws_security_group.controller.id
}

resource "aws_security_group_rule" "allow_ssh_controller" {
  count             = var.enable_ssh_to_controller ? 1 : 0
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = var.allow_cidr_blocks_to_workers
  security_group_id = aws_security_group.controller.id
}

resource "aws_security_group_rule" "allow_egress_controller" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.controller.id
}