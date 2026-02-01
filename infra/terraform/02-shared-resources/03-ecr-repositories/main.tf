resource "aws_ecr_repository" "this" {
  name                 = var.repository_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(var.common_tags, {
    Name   = var.repository_name
    Module = "02-shared-resources/03-ecr-repositories"
  })
}

resource "aws_ecr_lifecycle_policy" "this" {
  repository = aws_ecr_repository.this.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

resource "aws_ssm_parameter" "ecr_repository_name" {
  name        = "/${var.project_name}/02-shared-resources/03-ecr-repositories/ecr-repository"
  description = "ECR Repository Name"
  type        = "String"
  value       = aws_ecr_repository.this.name

  tags = merge(var.common_tags, {
    Module = "02-shared-resources/03-ecr-repositories"
  })
}
