variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "eu-south-2"
}

variable "aws_profile" {
  description = "AWS CLI profile to use for credentials"
  type        = string
  default     = "terraform"
}

variable "domain_name" {
  description = "Primary domain name for the certificate and distribution"
  type        = string
  default     = "agevega.com"
}

variable "enable_waf" {
  description = "Enable WAF auto-discovery. Set to false to force WAF detachment before destroying the WAF module."
  type        = bool
  default     = true
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {
    Project     = "agevegacom"
    Environment = "lab"
    ManagedBy   = "terraform"
    Module      = "05-cloudfront-WAF-S3/03-cloudfront"
  }
}
