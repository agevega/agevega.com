# ------------------------------------------------------------------------------
# Landing — agevega.com
# ------------------------------------------------------------------------------

resource "aws_ecr_repository" "landing" {
  name                 = var.repository_name_landing
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(var.common_tags, {
    Name = var.repository_name_landing
    Site = "landing"
  })
}

resource "aws_ecr_lifecycle_policy" "landing" {
  repository = aws_ecr_repository.landing.name

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

resource "aws_ssm_parameter" "ecr_repository_name_landing" {
  name        = "/${var.project_name}/02-shared-resources/01-ecr-repositories/ecr-repository-landing"
  description = "ECR Repository Name (landing site)"
  type        = "String"
  value       = aws_ecr_repository.landing.name

  tags = var.common_tags
}

# ------------------------------------------------------------------------------
# Academy — academy.agevega.com
# ------------------------------------------------------------------------------

resource "aws_ecr_repository" "academy" {
  name                 = var.repository_name_academy
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(var.common_tags, {
    Name = var.repository_name_academy
    Site = "academy"
  })
}

resource "aws_ecr_lifecycle_policy" "academy" {
  repository = aws_ecr_repository.academy.name

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

resource "aws_ssm_parameter" "ecr_repository_name_academy" {
  name        = "/${var.project_name}/02-shared-resources/01-ecr-repositories/ecr-repository-academy"
  description = "ECR Repository Name (academy site)"
  type        = "String"
  value       = aws_ecr_repository.academy.name

  tags = var.common_tags
}
