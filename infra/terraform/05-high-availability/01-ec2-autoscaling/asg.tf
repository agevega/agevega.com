resource "aws_autoscaling_group" "app_asg" {
  name = "ha-cluster-asg"
  vpc_zone_identifier = [
    data.terraform_remote_state.vpc.outputs.subnet_private_1_id,
    data.terraform_remote_state.vpc.outputs.subnet_private_2_id,
    data.terraform_remote_state.vpc.outputs.subnet_private_3_id
  ]

  target_group_arns         = [aws_lb_target_group.app_tg.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 300

  min_size         = 1
  max_size         = 3
  desired_capacity = 2

  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "ha-cluster-node"
    propagate_at_launch = true
  }

  tag {
    key                 = "Module"
    value               = "05-high-availability/01-ec2-autoscaling"
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = var.common_tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }
}
