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

variable "assets_bucket_name" {
  description = "Name of the S3 bucket for assets"
  type        = string
  default     = "agevegacom-assets-private"
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {
    Project     = "agevegacom"
    Environment = "lab"
    ManagedBy   = "terraform"
    Module      = "05-cloudfront-WAF-S3/00-s3-assets"
  }
}
