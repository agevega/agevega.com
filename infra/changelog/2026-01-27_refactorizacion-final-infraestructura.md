# Refactorización Final y Consolidación de Infraestructura

**Fecha:** 27 de Enero de 2026
**Autor:** Alejandro Vega

## 📋 Resumen

Se ha completado la refactorización integral de la infraestructura en Terraform, consolidando los módulos en una estructura lineal (`00` a `05`) y mejorando la integración con el Frontend y los pipelines de CI/CD.

## 🏗️ Cambios en Infraestructura

### Consolidación de Módulos

Se reestructuró el proyecto eliminando dependencias circulares y módulos obsoletos:

1.  **00-setup**: Backend S3 y DynamoDB (renombrado de `00-backend-S3`).
2.  **01-networking**: Submódulos para VPC, NAT y Endpoints.
3.  **02-shared-resources**: Centralización de recursos globales (SSH Keys, ACM, S3 Assets, ECR) en un único módulo para facilitar el acceso desde otros.
4.  **03-backend-serverless**: API Formulario de Contacto (renombrado de `04-lambda-SES`).
    - **Fix CORS**: Añadido `dev.agevega.com` a los orígenes permitidos.
5.  **04-bastion-host**: Consolidación de Bastion + WAF + CloudFront Dev.
6.  **05-high-availability**: Consolidación de Cluster Prod (ASG + ALB + WAF Prod) (renombrado de `06-ha-autoscaling`).

### Actualizaciones Técnicas

- **Tags**: Implementación consistente del tag `Module` en todos los recursos para trazabilidad.
- **Backend**: Rutas de S3 state actualizadas en todos los `backend.tf` y `data.tf` para reflejar la nueva estructura de carpetas.
- **State Lock**: Limpieza manual de bloqueos en DynamoDB para corregir desincronizaciones durante la migración.

## 💻 Cambios en Frontend y CI/CD

### Frontend (Astro)

- **API Endpoint**: Actualización dinámica de la URL del API Gateway en `ContactSection.astro` tras el redespliegue de la infraestructura serverless.

### GitHub Actions

- **Pipeline Bastion (`01-deploy-to-ec2.yml`)**:
  - **IP Dinámica**: Eliminada la IP fija ("hardcoded"). Ahora el pipeline busca automáticamente la IP pública de la instancia con tag `Name=bastion-host`.
  - **CloudFront Dev**: Invalidez de caché apuntando específicamente al alias `dev.agevega.com`.
  - **Linting**: Corrección de warnings de contexto indefinido mediante placeholders.

## 📝 Próximos Pasos de Mantenimiento

- Ejecutar `terraform init -reconfigure` en cualquier despliegue futuro debido a los cambios de rutas en el backend.
- Verificar periódicamente el estado de verificación de emails en SES si se destruye el módulo 03.
