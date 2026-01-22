variable "aws_region" {
  description = "AWS region where the network resources are deployed"
  type        = string
  default     = "eu-south-2"
}

variable "aws_profile" {
  description = "AWS CLI profile to use for credentials"
  type        = string
  default     = "terraform"
}

variable "resource_prefix" {
  description = "Prefix used for tagging and naming AWS resources"
  type        = string
  default     = "agevegacom"
}

variable "common_tags" {
  description = "Standard tags applied to every resource"
  type        = map(string)
  default = {
    Project     = "agevegacom"
    Owner       = "Alejandro Vega"
    Environment = "lab"
    ManagedBy   = "terraform"
  }
}

variable "vpc_cidr" {
  description = "CIDR block for the core VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "CIDR blocks for the public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnets" {
  description = "CIDR blocks for the private subnets"
  type        = list(string)
  default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "db_subnets" {
  description = "CIDR blocks for the database subnets"
  type        = list(string)
  default     = ["10.0.7.0/24", "10.0.8.0/24", "10.0.9.0/24"]
}

variable "availability_zones" {
  description = "Availability zones used to spread the subnets"
  type        = list(string)
  default     = ["eu-south-2a", "eu-south-2b", "eu-south-2c"]
}
