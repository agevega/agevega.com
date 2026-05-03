variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "eu-south-2"
}

variable "aws_profile" {
  description = "AWS CLI Profile"
  type        = string
  default     = "terraform"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "agevegacom"
}

variable "common_tags" {
  description = "Common tags"
  type        = map(string)
  default = {
    Project     = "agevegacom"
    Owner       = "Alejandro Vega"
    ManagedBy   = "terraform"
    Environment = "global"
    Module      = "02-shared-resources/01-ecr-repositories"
  }
}

variable "repository_name_landing" {
  description = "The name of the ECR repository for the landing site"
  type        = string
  default     = "agevegacom-landing"
}

variable "repository_name_academy" {
  description = "The name of the ECR repository for the academy site"
  type        = string
  default     = "agevegacom-academy"
}
