variable "aws_profile" {
  description = "AWS CLI profile to use for credentials"
  type        = string
  default     = "terraform"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "agevegacom"
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {
    Project     = "agevegacom"
    Environment = "lab"
    ManagedBy   = "terraform"
    Module      = "05-cloudfront-WAF-S3/02-waf"
  }
}
