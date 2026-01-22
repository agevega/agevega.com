# 21/01/2026 — Implementación de Budgets y Estandarización de Etiquetas

## 📝 Descripción

Se ha implementado un nuevo módulo de control de costes (`02-budgets`) y se ha estandarizado la estrategia de etiquetado en toda la infraestructura para garantizar una mejor gobernanza y visibilidad de los recursos.

## 🏗 Nuevo Módulo: 02-budgets

Despliegue de alertas de presupuesto en AWS Budgets para monitorizar el gasto mensual y diario.

- **Presupuesto Mensual**: 10$ (Alertas al 50%, 80%, 100% real y 200% proyectado).
- **Presupuesto Diario**: 1$ (Alertas progresivas desde el 50% al 1000%).
- **Configuración**:
  - Sin fecha de finalización (Indefinido).
  - Notificaciones vía email (`agevega@gmail.com`).

## 🏷️ Estandarización de Etiquetas (Tagging)

Se ha refactorizado el código Terraform de **todos los módulos** para aplicar una estructura de etiquetas consistente:

- **Common Tags**: `Project`, `Environment`, `Owner`, `ManagedBy`.
- **Module Tag**: Se añade automáticamente la etiqueta `Module` con la ruta relativa del componente (ej: `02-bastion-EC2/00-security`).

### Módulos actualizados:

- `00-setup/00-backend-S3`
- `00-setup/01-audit-logs`
- `01-networking`
- `02-bastion-EC2`
- `03-ECR`
- `04-lambda-SES`
- `05-cloudfront-WAF-S3`

## 🔧 Correcciones de Documentación e Infraestructura

- **Backend Keys**: Se ha corregido la estructura de keys en el backend S3 para seguir el patrón `modules/<RUTA>/terraform.tfstate`, eliminando la referencia obsoleta a `envs/lab`.
- **Nombres de Buckets**: Actualizada la documentación para reflejar los nombres reales de los buckets (`agevegacom-terraform-state`, `agevegacom-cloudtrail-logs`, etc.).
