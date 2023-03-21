resource "aws_instance" "worker" {
  count                       = var.num_workers
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  iam_instance_profile        = module.iam.iam_instance_profile.name
  subnet_id                   = var.public_subnet_ids[count.index]
  key_name                    = var.key_pair_name
  vpc_security_group_ids      = [aws_security_group.worker.id]
  associate_public_ip_address = true

  ebs_block_device {
    delete_on_termination = true
    device_name           = "/dev/sdf"
    encrypted             = false

    tags = merge(local.tags, {
      Name      = "${var.name}-boundary-worker",
      Component = "worker",
      Purpose   = "boundary-audit-logs"
    })

    volume_size = 32
    volume_type = "gp2"
  }

  user_data = templatefile("${path.module}/templates/user_data_worker.tmpl.sh", {
    name                    = var.name
    index                   = count.index
    controller_ips          = aws_instance.controller.*.private_ip
    kms_worker_auth_key_id  = aws_kms_key.worker_auth.id
    boundary_sink_file_path = var.boundary_sink_file_path
    boundary_sink_file_name = var.boundary_sink_file_name
    datadog_api_key         = var.datadog_api_key
  })

  tags = merge(local.tags, {
    Name      = "${var.name}-boundary-worker",
    Component = "worker"
  })

  depends_on = [aws_instance.controller]
}

resource "aws_security_group" "worker" {
  vpc_id = var.vpc_id

  tags = merge(local.tags, {
    Name      = "${var.name}-boundary-worker",
    Component = "worker"
  })
}

resource "aws_security_group_rule" "allow_9201_worker" {
  type              = "ingress"
  from_port         = 9201
  to_port           = 9201
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_cidr_block]
  security_group_id = aws_security_group.worker.id
}

resource "aws_security_group_rule" "allow_9202_worker" {
  type              = "ingress"
  from_port         = 9202
  to_port           = 9202
  protocol          = "tcp"
  cidr_blocks       = var.allow_cidr_blocks_to_workers
  security_group_id = aws_security_group.worker.id
}

resource "aws_security_group_rule" "allow_egress_worker" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.worker.id
}
