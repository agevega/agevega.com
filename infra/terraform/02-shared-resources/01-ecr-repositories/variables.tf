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

variable "project_name" {
  description = "Project name for SSM paths"
  type        = string
  default     = "agevegacom"
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "agevegacom"
    Owner       = "Alejandro Vega"
    Environment = "global"
    ManagedBy   = "terraform"
    Module      = "02-shared-resources/01-ecr-repositories"
  }
}

variable "repository_name" {
  description = "The name of the ECR repository"
  type        = string
  default     = "agevegacom-frontend"
}
