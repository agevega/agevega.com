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
    Module      = "02-shared-resources/02-s3-buckets"
  }
}

variable "assets_bucket_name" {
  description = "Name of the S3 bucket for assets"
  type        = string
  default     = "agevegacom-assets-private"
}
