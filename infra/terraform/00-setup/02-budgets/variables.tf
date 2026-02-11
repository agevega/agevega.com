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
    Module      = "00-setup/02-budgets"
  }
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
