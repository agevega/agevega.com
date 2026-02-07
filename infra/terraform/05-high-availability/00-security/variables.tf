variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "eu-south-2"
}

variable "aws_profile" {
  description = "AWS CLI profile"
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
    Environment = "prod"
    ManagedBy   = "terraform"
    Module      = "05-high-availability/00-security"
  }
}

variable "domain_name" {
  description = "Domain name for ACM certificate and Route53 lookup"
  type        = string
  default     = "agevega.com"
}
