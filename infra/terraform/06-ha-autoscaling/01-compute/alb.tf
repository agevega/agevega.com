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

  tags = merge(var.common_tags, {
    Name = "ha-cluster-alb"
  })
}

resource "aws_lb_target_group" "app_tg" {
  name        = "ha-cluster-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  target_type = "instance"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = var.common_tags
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}
