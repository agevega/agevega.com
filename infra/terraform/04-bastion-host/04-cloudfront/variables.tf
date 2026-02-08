variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "eu-south-2"
}

variable "aws_profile" {
  description = "AWS CLI profile to use for credentials"
  type        = string
  default     = "terraform"
}

variable "domain_name" {
  description = "Primary domain name for the certificate and distribution"
  type        = string
  default     = "agevega.com"
}

variable "enable_waf" {
  description = "Enable WAF auto-discovery. Set to false to force WAF detachment before destroying the WAF module."
  type        = bool
  default     = false
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    Project     = "agevegacom"
    Environment = "dev"
    ManagedBy   = "terraform"
    Module      = "04-bastion-host/04-cloudfront"
  }
}

variable "project_name" {
  description = "Project name for SSM paths"
  type        = string
  default     = "agevegacom"
}
