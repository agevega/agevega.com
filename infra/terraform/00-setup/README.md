# 00-setup

Este módulo gestiona el setup inicial de la infraestructura (backend y auditoría).

Está dividido en dos submódulos críticos que deben ejecutarse en orden:

1.  **`00-backend-S3`**: Bootstrap de IaC. Crea el bucket S3 y la tabla DynamoDB para guardar el estado de Terraform.
2.  **`01-init-config`**: Configuración de auditoría. Habilita AWS CloudTrail y AWS Config para compliance y seguridad.

![Architecture Diagram](../../diagrams/00-terraform-state-S3.png)

---

## 🚀 Guía de Despliegue (Fresh Account)

### Paso 1: Bootstrap (00-backend-S3)

Crea la infraestructura base para que Terraform pueda guardar su estado.

```bash
cd 00-backend-S3
terraform init
terraform apply
```

> **Nota**: Este paso usa un estado local temporalmente hasta que el bucket existe.
>
> **Cómo migrar al estado remoto (Recomendado):**
>
> Una vez que el bucket y la tabla DynamoDB se hayan creado:
>
> 1. Abre el archivo `backend.tf` (ya incluido en la carpeta `00-backend-S3`).
> 2. Descomenta el bloque de configuración `terraform { ... }`.
>
> Luego, ejecuta:
>
> ```bash
> terraform init -migrate-state
> ```
>
> Responde `yes` para copiar tu estado local existente al bucket S3.

### Paso 2: Auditoría (01-init-config)

Habilita los logs de auditoría obligatorios.

```bash
cd 01-init-config
terraform init
terraform apply
```

---

## 📂 Contenido del Módulo

### 00-backend-S3

- **Bucket S3**: `terraform-state-agevegacom`. Versionado, encriptado (AES256), sin acceso público.
- **DynamoDB**: `terraform-state-lock`. LockID key, PITR activo.

### 01-init-config

- **CloudTrail**: `agevegacom-trail`. Multi-región, validación de logs activa, eventos de gestión.
- **AWS Config**: Grabación continua de todos los recursos (incluido globales), retención 90 días.
- **Buckets de Logs**: `cloudtrail-logs-agevegacom` y `aws-config-logs-agevegacom`.

---

## ⚙️ Uso en otros proyectos

Para que otros módulos guarden su estado en esta infraestructura, añade el bloque `backend "s3"` en su configuración:

```hcl
terraform {
  backend "s3" {
    bucket         = "terraform-state-agevegacom"
    key            = "envs/lab/agevegacom/<NOMBRE_MODULO>/terraform.tfstate"
    region         = "eu-south-2"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
    profile        = "terraform"
  }
}
```
