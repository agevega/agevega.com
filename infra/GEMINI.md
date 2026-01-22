# Contexto: Infraestructura (`/infra`)

## 🛠 Stack Tecnológico

- **IaC**: Terraform.
- **Cloud**: AWS (Región: `eu-south-2` - Madrid).

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
