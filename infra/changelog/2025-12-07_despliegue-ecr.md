# 07/12/2025 — Despliegue de repositorio ECR (Módulo 03)

Se ha creado un nuevo módulo Terraform (`infra/terraform/03-ECR`) para gestionar el repositorio de imágenes Docker del frontend.

### 📦 Módulo 03-ECR

- **Recurso principal**: `aws_ecr_repository` para almacenar imágenes Docker.
- **Seguridad**:
  - Activación de escaneo de vulnerabilidades en _push_ (`image_scanning_configuration`).
  - Configuración de políticas de ciclo de vida (`aws_ecr_lifecycle_policy`) para conservar únicamente las últimas 10 imágenes y optimizar costes de almacenamiento.
- **Configuración estándar**:
  - Implementación de `versions.tf`, `provider.tf` y `backend.tf` alineada con los módulos de red (`01-networking`) y computación (`02-bastion-EC2`).
  - Uso de backend S3 remoto con bloqueo DynamoDB.
- **Outputs**: Exportación de la URL y ARN del repositorio para su uso en pipelines de despliegue.
