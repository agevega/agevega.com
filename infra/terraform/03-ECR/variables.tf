variable "repository_name" {
  description = "The name of the ECR repository"
  type        = string
  default     = "agevegacom-frontend"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-south-2"
}

variable "aws_profile" {
  description = "AWS profile"
  type        = string
  default     = "terraform"
}
