variable "aws_region" {
  description = "AWS region for state resources"
  type        = string
  default     = "eu-south-2"
}

variable "aws_profile" {
  description = "AWS CLI profile to use"
  type        = string
  default     = "terraform"
}

variable "resource_prefix" {
  description = "Prefix used in names/tags for backend resources"
  type        = string
  default     = "agevegacom"
}

variable "state_bucket_name" {
  description = "Globally unique name of the S3 bucket for Terraform state"
  type        = string
  default     = "agevegacom-terraform-state"
}

variable "lock_table_name" {
  description = "Name of the DynamoDB table for state locking"
  type        = string
  default     = "terraform-state-lock"
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Project = "agevegacom"
    Owner   = "Alejandro Vega"
    IaC     = "Terraform"
  }
}
