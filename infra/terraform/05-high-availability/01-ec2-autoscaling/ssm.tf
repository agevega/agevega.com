resource "aws_ssm_parameter" "image_tag" {
  name        = "/${var.project_name}/production/image_tag"
  description = "Docker image tag (shared across all sites) in Production environment"
  type        = "String"
  value       = "latest"

  lifecycle {
    ignore_changes = [value]
  }

  tags = merge(var.common_tags, {
    Name = "production-image-tag"
  })
}

resource "aws_ssm_parameter" "asg_name" {
  name        = "/${var.project_name}/05-high-availability/01-ec2-autoscaling/asg-name"
  description = "Auto Scaling Group name (used by workflow 02 for instance refresh)"
  type        = "String"
  value       = aws_autoscaling_group.app_asg.name

  tags = merge(var.common_tags, {
    Name = "ha-cluster-asg"
  })
}
