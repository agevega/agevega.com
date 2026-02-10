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
  description = "Primary domain name"
  type        = string
  default     = "agevega.com"
}

variable "common_tags" {
  description = "Common tags"
  type        = map(string)
  default     = {
    Project     = "agevegacom"
    Environment = "prod"
    ManagedBy   = "terraform"
    Module      = "05-high-availability/04-dns-record"
  }
}
