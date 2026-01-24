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

variable "domain_name" {
  description = "Domain name"
  type        = string
  default     = "agevega.com"
}

variable "common_tags" {
  description = "Common tags"
  type        = map(string)
  default     = {
    Project     = "agevegacom"
    Environment = "prod"
    ManagedBy   = "terraform"
    Module      = "06-ha-autoscaling/02-cloudfront"
  }
}
