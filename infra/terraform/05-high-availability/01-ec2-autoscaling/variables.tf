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
  }
}

variable "instance_type" {
  description = "Instance type for ASG (Spot)"
  type        = string
  default     = "t4g.nano"
}


