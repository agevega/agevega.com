# 22/01/2026 — Refactorización de Networking y Auditoría de Documentación

## 📝 Descripción

Se ha realizado una refactorización del módulo de red (`01-networking`) para mejorar la modularidad y gestión de costes, junto con una auditoría completa de la documentación y consistencia del proyecto.

## 🏗 Refactorización de Networking

El módulo `01-networking` se ha dividido en tres submódulos independientes para permitir un ciclo de vida granular de los recursos costosos (NAT Gateway):

1.  **`00-vpc-core`**:
    - Contiene los recursos base: VPC, Subnets (Public/Private/DB), Internet Gateway y Route Tables.
    - **Estado**: Siempre activo.
2.  **`01-nat-gateway`**:
    - Contiene la Elastic IP y el NAT Gateway.
    - **Mejora**: Ahora es opcional. Se puede desplegar solo cuando se necesite salir a internet desde redes privadas (ej: actualizaciones) y destruir después para ahorrar (~33€/mes).
3.  **`02-vpc-endpoints`**:
    - Contiene el Gateway Endpoint de S3.
    - **Mejora**: Desacoplado del core para mantenibilidad.

### ⚠️ Cambios Importantes (Breaking Changes)

- **State Path**: Los `backend keys` han cambiado de `modules/01-networking/terraform.tfstate` a rutas específicas por submódulo:
  - `modules/01-networking/00-vpc-core/terraform.tfstate`
  - `modules/01-networking/01-nat-gateway/terraform.tfstate`
  - `modules/01-networking/02-vpc-endpoints/terraform.tfstate`
- **Dependencias**: Los módulos que dependían de networking (`02-bastion-EC2`) han sido actualizados para leer los outputs desde `00-vpc-core`.
