resource "aws_lb" "controller" {
  name               = var.name
  load_balancer_type = "application"
  internal           = false
  subnets            = var.public_subnet_ids
  security_groups    = [aws_security_group.controller_lb.id]

  tags = merge(local.tags, { Component = "controller" })
}

resource "aws_lb_target_group" "controller" {
  name     = var.name
  port     = 9200
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  stickiness {
    enabled = false
    type    = "lb_cookie"
  }

  tags = merge(local.tags, { Component = "controller" })
}

resource "aws_lb_target_group_attachment" "controller" {
  count            = var.num_controllers
  target_group_arn = aws_lb_target_group.controller.arn
  target_id        = aws_instance.controller[count.index].id
  port             = 9200
}

resource "aws_lb_listener" "controller" {
  load_balancer_arn = aws_lb.controller.arn
  port              = "9200"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.controller.arn
  }
}

resource "aws_security_group" "controller_lb" {
  vpc_id = var.vpc_id

  tags = merge(local.tags, { Component = "controller" })
}

resource "aws_security_group_rule" "allow_9200" {
  type              = "ingress"
  from_port         = 9200
  to_port           = 9200
  protocol          = "tcp"
  cidr_blocks       = var.allow_cidr_blocks_to_api
  security_group_id = aws_security_group.controller_lb.id
}

resource "aws_security_group_rule" "lb_egress" {
  type                     = "egress"
  from_port                = 9200
  to_port                  = 9200
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.controller.id
  security_group_id        = aws_security_group.controller_lb.id
}
