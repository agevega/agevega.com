variable "aws_region" {
  description = "Región AWS para los recursos del estado"
  type        = string
  default     = "eu-south-2"
}

variable "aws_profile" {
  description = "Perfil de AWS CLI a usar"
  type        = string
  default     = "terraform"
}

variable "resource_prefix" {
  description = "Prefix used in names/tags for backend resources"
  type        = string
  default     = "agevegacom"
}

variable "state_bucket_name" {
  description = "Nombre globalmente único del bucket S3 para el estado de Terraform"
  type        = string
  default     = "terraform-state-agevegacom"
}

variable "lock_table_name" {
  description = "Nombre de la tabla DynamoDB para el locking del estado"
  type        = string
  default     = "terraform-state-lock"
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Project = "agevegacom"
    Owner   = "Alejandro Vega"
    IaC     = "Terraform"
  }
}
