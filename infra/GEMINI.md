# Contexto: Infraestructura (`/infra`)

## 🛠 Stack Tecnológico

- **IaC**: Terraform.
- **Cloud**: AWS (Región: `eu-south-2` - Madrid).
- **State Lock**: DynamoDB.

## 📏 Guías de Desarrollo

- **Estructura**: Módulos numerados (e.g., `01-networking`, `02-bastion`).
- **Convenciones**:
  - Recursos: `snake_case`.
  - Variables: Siempre incluir `description` y `type`.
- **Seguridad**:
  - Least Privilege en IAM Roles.
  - Security Groups estrictos (Whitelisting).
- **Recursos Principales**:
  - **VPC**: 3 capas (Public, Private, Data).
  - **Bastion**: EC2 t4g.nano (ARM) con acceso restringido.
  - **CDN**: CloudFront con OAC para S3 (si aplica) o Proxy a EC2.
  - **Serverless**: Lambda (Python ARM64) + API Gateway para lógica backend.
