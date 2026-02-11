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
    Environment = "dev"
    ManagedBy   = "terraform"
    Module      = "04-bastion-host/05-dns-record"
  }
}

variable "domain_name" {
  description = "Primary domain name"
  type        = string
  default     = "agevega.com"
}
