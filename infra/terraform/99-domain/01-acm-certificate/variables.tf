variable "aws_profile" {
  description = "AWS CLI profile to use for credentials"
  type        = string
  default     = "terraform"
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {
    Project     = "agevegacom"
    Environment = "global"
    ManagedBy   = "terraform"
    Module      = "99-domain/01-acm-certificate"
  }
}

variable "domain_name" {
  description = "Primary domain name for the certificate"
  type        = string
  default     = "agevega.com"
}
