resource "aws_launch_template" "app_lt" {
  name_prefix   = "ha-cluster-lt-"
  image_id      = var.ami_id
  instance_type = var.instance_type

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  vpc_security_group_ids = [aws_security_group.instance_sg.id]

  user_data = base64encode(templatefile("${path.module}/user_data.sh.tpl", {
    aws_region     = var.aws_region
    repository_url = data.terraform_remote_state.ecr.outputs.repository_url
  }))

  instance_market_options {
    market_type = "spot"
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.common_tags, {
      Name = "ha-cluster-node"
    })
  }

  lifecycle {
    create_before_destroy = true
  }
}
