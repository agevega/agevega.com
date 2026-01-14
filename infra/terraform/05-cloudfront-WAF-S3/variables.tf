variable "project_name" {
  description = "Project name"
  type        = string
  default     = "agevegacom"
}

variable "domain_name" {
  description = "Primary domain name for the certificate and distribution"
  type        = string
  default     = "agevega.com"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "lab"
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {
    Project     = "agevegacom"
    Environment = "lab"
    ManagedBy   = "terraform"
    Module      = "05-cloudfront-waf"
  }
}

variable "assets_bucket_name" {
  description = "Name of the S3 bucket for assets"
  type        = string
  default     = "agevegacom-assets-private"
}
