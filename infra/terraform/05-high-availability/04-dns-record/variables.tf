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
    Environment = "prod"
    Module      = "05-high-availability/04-dns-record"
  }
}

variable "domain_name" {
  description = "Primary domain name"
  type        = string
  default     = "agevega.com"
}

variable "dev_cloudfront" {
  description = "Point DNS to the development CloudFront (04-bastion-host) instead of production"
  type        = bool
  default     = false
}
