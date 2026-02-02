variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "eu-south-2"
}

variable "aws_profile" {
  description = "AWS CLI profile"
  type        = string
  default     = "terraform"
}

variable "common_tags" {
  description = "Common tags"
  type        = map(string)
  default = {
    Project     = "agevegacom"
    Owner       = "Alejandro Vega"
    Environment = "prod"
    ManagedBy   = "terraform"
    Module      = "05-high-availability/00-security"
  }
}
