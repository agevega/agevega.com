# 14/01/2026 — Consolidación de Assets y CloudFront (Módulo 05)

## 📝 Descripción

Refactorización de la infraestructura para servir archivos estáticos privados (como el CV) de forma segura. Se ha consolidado la creación del bucket de assets dentro del módulo de CloudFront para eliminar dependencias circulares y simplificar el despliegue.

## 🏗 Arquitectura Final

- **S3 Assets Bucket**: `agevegacom-assets-private`
  - Totalmente privado (Block Public Access).
  - Cifrado SSE-S3.
- **CloudFront Integration**:
  - Nuevo origen S3 configurado con **OAC (Origin Access Control)**.
  - Behavior ordenado para ruta `/assets/*`.
- **Simplificación**:
  - El módulo `05-cloudfront-waf` ha sido renombrado a `05-cloudfront-WAF-S3`.

## ⚙️ Cambios realizados

### Infraestructura

1.  **Renombrado**: `05-cloudfront-waf` -> `05-cloudfront-WAF-S3`.
2.  **Backend Key**: Actualizada la ruta del estado de Terraform a `modules/05-cloudfront-WAF-S3/terraform.tfstate`.

### Frontend

1.  **AboutSection.astro**:
    - Actualizado enlace de descarga de CV para apuntar a `/assets/cv-alejandro-vega.pdf`.
    - Añadido atributo `download`.

## 💰 Impacto en Costes

- **S3**: Coste marginal por almacenamiento (< 0.01€/mes).
- **Transferencia**: Incluida en capa gratuita de CloudFront.
