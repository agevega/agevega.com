resource "aws_ssm_parameter" "image_tag" {
  name        = "/${var.project_name}/production/image_tag"
  description = "Docker image tag for landing in Production environment"
  type        = "String"
  value       = "latest"

  lifecycle {
    ignore_changes = [value]
  }

  tags = merge(var.common_tags, {
    Name = "production-image-tag"
    Site = "landing"
  })
}

resource "aws_ssm_parameter" "image_tag_academy" {
  name        = "/${var.project_name}/production/image_tag_academy"
  description = "Docker image tag for academy in Production environment"
  type        = "String"
  value       = "latest"

  lifecycle {
    ignore_changes = [value]
  }

  tags = merge(var.common_tags, {
    Name = "production-image-tag-academy"
    Site = "academy"
  })
}
