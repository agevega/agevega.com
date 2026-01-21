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

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "agevegacom"
}

variable "monthly_budget_amount" {
  description = "Monthly budget amount in USD"
  type        = string
  default     = "10"
}

variable "daily_budget_amount" {
  description = "Daily budget amount in USD"
  type        = string
  default     = "1"
}

variable "notification_email" {
  description = "Email address for budget notifications"
  type        = string
  default     = "agevega@gmail.com"
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "agevegacom"
    Owner       = "Alejandro Vega"
    Environment = "global"
    ManagedBy   = "terraform"
  }
}
