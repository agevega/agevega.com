variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-south-2"
}

variable "aws_profile" {
  description = "AWS profile"
  type        = string
  default     = "terraform"
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

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "agevegacom"
}
