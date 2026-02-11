resource "aws_ssm_parameter" "image_tag" {
  name        = "/${var.project_name}/production/image_tag"
  description = "Docker image tag for Production environment"
  type        = "String"
  value       = "latest"

  lifecycle {
    ignore_changes = [value]
  }

  tags = merge(var.common_tags, {
    Name = "production-image-tag"
  })
}
