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

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "agevegacom"
    Owner       = "Alejandro Vega"
    Environment = "lab"
    ManagedBy   = "terraform"
  }
}
