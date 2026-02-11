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
  description = "Project name for SSM paths"
  type        = string
  default     = "agevegacom"
}

variable "common_tags" {
  description = "Common tags"
  type        = map(string)
  default = {
    Project     = "agevegacom"
    Owner       = "Alejandro Vega"
    Environment = "dev"
    ManagedBy   = "terraform"
    Module      = "04-bastion-host/04-cloudfront"
  }
}

variable "domain_name" {
  description = "Domain name"
  type        = string
  default     = "agevega.com"
}

variable "enable_waf" {
  description = "Enable WAF attachment to CloudFront"
  type        = bool
  default     = false
}
