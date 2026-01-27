resource "aws_launch_template" "app_lt" {
  name_prefix   = "ha-cluster-lt-"
  image_id      = data.aws_ami.amazon_linux_2023.id
  instance_type = var.instance_type
  key_name      = data.terraform_remote_state.ssh_key.outputs.key_name

  iam_instance_profile {
    name = data.terraform_remote_state.security.outputs.instance_profile_name
  }

  vpc_security_group_ids = [data.terraform_remote_state.security.outputs.instance_sg_id]

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

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }
}
