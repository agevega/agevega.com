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

variable "domain_name" {
  description = "Domain name"
  type        = string
  default     = "agevega.com"
}

variable "enable_waf" {
  description = "Enable WAF attachment to CloudFront"
  type        = bool
  default     = true
}

variable "common_tags" {
  description = "Common tags"
  type        = map(string)
  default = {
    Project     = "agevegacom"
    Owner       = "Alejandro Vega"
    Environment = "prod"
    ManagedBy   = "terraform"
    Module      = "05-high-availability/03-cloudfront"
  }
}

variable "project_name" {
  description = "Project name for SSM paths"
  type        = string
  default     = "agevegacom"
}
