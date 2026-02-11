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
    Environment = "global"
    Module      = "03-backend-serverless/00-contact-api"
  }
}

variable "ses_region" {
  description = "AWS region for SES (must support SES)"
  type        = string
  default     = "eu-west-1"
}

variable "sender_email" {
  description = "Email address to send from (must be verified in SES)"
  type        = string
  default     = "agevega@gmail.com"
}

variable "recipient_email" {
  description = "Email address to send to (must also be verified if in SES Sandbox)"
  type        = string
  default     = "agevega@gmail.com"
}
