resource "aws_lb" "app_alb" {
  name               = "ha-cluster-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [data.terraform_remote_state.security.outputs.alb_sg_id]
  subnets = [
    data.terraform_remote_state.vpc.outputs.subnet_public_1_id,
    data.terraform_remote_state.vpc.outputs.subnet_public_2_id,
    data.terraform_remote_state.vpc.outputs.subnet_public_3_id
  ]

  enable_deletion_protection = false
  drop_invalid_header_fields = true

  tags = merge(var.common_tags, {
    Name = "ha-cluster-alb"
  })
}

resource "aws_lb_target_group" "app_tg_landing" {
  name        = "ha-cluster-tg"
  port        = 443
  protocol    = "HTTPS"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  target_type = "instance"

  health_check {
    path                = "/health"
    protocol            = "HTTPS"
    matcher             = "200"
    interval            = 20
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = merge(var.common_tags, {
    Site = "landing"
  })
}

# Academy target group: instances expose academy container on host port 8443
resource "aws_lb_target_group" "app_tg_academy" {
  name        = "ha-cluster-tg-academy"
  port        = 8443
  protocol    = "HTTPS"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  target_type = "instance"

  health_check {
    path                = "/health"
    protocol            = "HTTPS"
    port                = "8443"
    matcher             = "200"
    interval            = 20
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = merge(var.common_tags, {
    Site = "academy"
  })
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = data.terraform_remote_state.acm.outputs.certificate_arn

  # Default action forwards to landing target group (preserves existing behavior).
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg_landing.arn
  }
}

# Listener rule: route academy.agevega.com + www.academy.agevega.com to academy TG.
# Default action above still serves landing for all other hosts.
resource "aws_lb_listener_rule" "academy" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg_academy.arn
  }

  condition {
    host_header {
      values = [
        "academy.${var.domain_name}",
        "www.academy.${var.domain_name}",
      ]
    }
  }

  tags = merge(var.common_tags, {
    Site = "academy"
  })
}
