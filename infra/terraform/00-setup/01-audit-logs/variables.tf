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
    Module      = "00-setup/01-audit-logs"
  }
}

variable "cloudtrail_name" {
  description = "Name of the CloudTrail trail"
  type        = string
  default     = "agevegacom-trail"
}

variable "cloudtrail_bucket_name" {
  description = "Name of S3 bucket for CloudTrail logs"
  type        = string
  default     = "agevegacom-cloudtrail-logs"
}

variable "config_bucket_name" {
  description = "Name of S3 bucket for AWS Config logs"
  type        = string
  default     = "agevegacom-aws-config-logs"
}

variable "enable_config" {
  description = "Enable or disable AWS Config recorder"
  type        = bool
  default     = true
}

variable "config_recording_frequency" {
  description = "Recording frequency for AWS Config (CONTINUOUS or DAILY)"
  type        = string
  default     = "CONTINUOUS"
}
