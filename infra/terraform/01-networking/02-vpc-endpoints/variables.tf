variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-south-2"
}

variable "aws_profile" {
  description = "AWS CLI profile"
  type        = string
  default     = "terraform"
}

variable "resource_prefix" {
  description = "Prefix used for tagging and naming AWS resources"
  type        = string
  default     = "agevegacom"
}

variable "common_tags" {
  description = "Standard tags applied to every resource"
  type        = map(string)
  default = {
    Project     = "agevegacom"
    Owner       = "Alejandro Vega"
    Environment = "lab"
    ManagedBy   = "terraform"
  }
}
