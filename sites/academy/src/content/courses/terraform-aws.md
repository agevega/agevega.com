---
title: Terraform en AWS — Infraestructura como Código
description: Provisiona infraestructura en AWS de forma reproducible y versionada con Terraform. VPC, EC2, S3, IAM y estado remoto en S3 + DynamoDB desde cero.
youtubeId: dQw4w9WgXcQ
category: cloud
tags: [terraform, aws, iac, infraestructura, cloud]
order: 3
publishedAt: 2024-03-05
difficulty: intermediate
resources:
  - label: Repositorio con los módulos del curso
    url: https://github.com/agevega/academy-terraform-aws
  - label: Documentación de Terraform
    url: https://developer.hashicorp.com/terraform/docs
  - label: Registro de providers de Terraform
    url: https://registry.terraform.io/providers/hashicorp/aws/latest/docs
  - label: AWS Free Tier — cuenta gratuita
    url: https://aws.amazon.com/free/
---

## ¿Qué es Infraestructura como Código?

IaC (Infrastructure as Code) significa definir y gestionar infraestructura mediante archivos de configuración en lugar de hacerlo manualmente desde la consola. Terraform es la herramienta IaC más usada y soporta más de 1000 proveedores cloud.

Ventajas clave:
- **Reproducibilidad**: el mismo código genera la misma infraestructura siempre
- **Versionado**: la infraestructura vive en Git como el código de la aplicación
- **Colaboración**: los cambios pasan por Pull Requests y revisión de código
- **Rollback**: revertir infraestructura es tan fácil como un `git revert`

## Estructura básica de un proyecto Terraform

```
infra/
├── main.tf          # Recursos principales
├── variables.tf     # Definición de variables
├── outputs.tf       # Valores de salida
├── versions.tf      # Versión de Terraform y providers
└── terraform.tfvars # Valores de variables (no comitear secretos)
```

## Configuración inicial

```hcl
# versions.tf
terraform {
  required_version = ">= 1.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Estado remoto en S3 (recomendado para equipos)
  backend "s3" {
    bucket         = "mi-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "eu-south-2"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}
```

## Tu primera VPC

```hcl
# main.tf
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.project}-vpc"
    Environment = var.environment
  }
}

resource "aws_subnet" "public" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
  availability_zone = var.availability_zones[count.index]

  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project}-public-${count.index + 1}"
    Tier = "public"
  }
}
```

## Comandos del ciclo de vida

```bash
# Inicializar (descarga providers, configura backend)
terraform init

# Ver los cambios que se aplicarán
terraform plan -out=tfplan

# Aplicar los cambios
terraform apply tfplan

# Ver el estado actual
terraform show

# Destruir infraestructura (¡cuidado en producción!)
terraform destroy
```

## IAM con mínimo privilegio

```hcl
# IAM role para una instancia EC2 con acceso a S3
resource "aws_iam_role" "app" {
  name = "${var.project}-app-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "app_s3" {
  name = "s3-access"
  role = aws_iam_role.app.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["s3:GetObject", "s3:PutObject"]
      Resource = "${aws_s3_bucket.assets.arn}/*"
    }]
  })
}
```

Principio de mínimo privilegio: solo los permisos que la aplicación realmente necesita.
