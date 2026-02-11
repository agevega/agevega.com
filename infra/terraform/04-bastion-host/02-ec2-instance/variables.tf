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
    Environment = "dev"
    Module      = "04-bastion-host/02-ec2-instance"
  }
}

variable "instance_type" {
  description = "EC2 Instance Type"
  type        = string
  default     = "t4g.nano"
}

variable "enable_eip" {
  description = "Enable Elastic IP for Bastion Host"
  type        = bool
  default     = false
}
