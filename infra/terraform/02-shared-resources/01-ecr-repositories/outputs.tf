output "repository_url_landing" {
  description = "The URL of the landing ECR repository"
  value       = aws_ecr_repository.landing.repository_url
}

output "repository_arn_landing" {
  description = "The ARN of the landing ECR repository"
  value       = aws_ecr_repository.landing.arn
}

output "repository_url_academy" {
  description = "The URL of the academy ECR repository"
  value       = aws_ecr_repository.academy.repository_url
}

output "repository_arn_academy" {
  description = "The ARN of the academy ECR repository"
  value       = aws_ecr_repository.academy.arn
}
