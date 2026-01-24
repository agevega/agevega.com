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
  default     = {
    Project     = "agevegacom"
    Environment = "prod"
    ManagedBy   = "terraform"
    Module      = "06-ha-autoscaling/01-compute"
  }
}

variable "instance_type" {
  description = "Instance type for ASG (Spot)"
  type        = string
  default     = "t3.small"
}

variable "ami_id" {
  description = "AMI ID (default: Ubuntu 24.04 LTS for eu-south-2)"
  type        = string
  default     = "ami-0b0dcb5067f052a63"
}
