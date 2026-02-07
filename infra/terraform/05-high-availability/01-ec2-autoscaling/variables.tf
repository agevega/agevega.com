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
    Environment = "prod"
    ManagedBy   = "terraform"
    Module      = "05-high-availability/01-ec2-autoscaling"
  }
}

variable "instance_type" {
  description = "Instance type for ASG (Spot)"
  type        = string
  default     = "t4g.nano"
}

variable "deploy_in_public_subnets" {
  description = "Deploy instances in public subnets with public IPs"
  type        = bool
  default     = false
}

variable "domain_name" {
  description = "Domain name for ACM certificate and Route53 lookup"
  type        = string
  default     = "agevega.com"
}
