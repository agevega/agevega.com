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

variable "resource_prefix" {
  description = "Prefix for resource naming"
  type        = string
  default     = "agevegacom"
}

variable "cloudtrail_bucket_name" {
  description = "Name of the existing S3 bucket for CloudTrail logs"
  type        = string
  default     = "cloudtrail-logs-agevegacom"
}

variable "cloudtrail_name" {
  description = "Name of the CloudTrail trail"
  type        = string
  default     = "agevegacom-trail"
}

variable "config_bucket_name" {
  description = "Name of the existing S3 bucket for AWS Config logs"
  type        = string
  default     = "aws-config-logs-agevegacom"
}
