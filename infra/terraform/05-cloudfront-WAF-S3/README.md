# 05-cloudfront-WAF-S3

Este módulo despliega la capa de distribución, seguridad perimetral y almacenamiento de assets privados para `agevega.com`.

Integrando tanto CloudFront como el bucket S3 en un solo módulo, garantizamos una gestión atómica de la infraestructura que sirve el contenido estático y los documentos privados.

---

## 🏛️ Arquitectura

### Componentes Principales

1.  **CloudFront Distribution**:

    - Actúa como punto de entrada único global.
    - **Origen 1 (Default)**: IP Elástica del Bastion EC2 (vía DNS Público).
    - **Origen 2 (Assets)**: Bucket S3 privado para documentos (e.g. CV).
    - **Protocolo Viewer**: HTTPS forzado (`redirect-to-https`).
    - **OAC (Origin Access Control)**: Mecanismo de seguridad para autenticar peticiones de CloudFront hacia S3.

2.  **S3 Assets Bucket**:

    - Bucket privado (`agevegacom-assets-private`) con cifrado SSE-S3.
    - **Block Public Access**: Totalmente habilitado. Nadie puede acceder directamente.
    - **Bucket Policy**: Permite acceso `s3:GetObject` únicamente a esta distribución específica de CloudFront.

3.  **AWS WAF (Opcional - DESACTIVADO)**:

    - _Desactivado actualmente para ahorro de costes (~6€/mes)._
    - Asociado a la distribución de CloudFront.

4.  **ACM Certificate**:
    - Certificado SSL/TLS público para `agevega.com` y `*.agevega.com`.

---

## 🚀 Guía de Despliegue

```bash
cd infra/terraform/05-cloudfront-WAF-S3
terraform init
terraform apply
```

> **Nota**: Si vienes de una versión anterior donde S3 era un módulo separado, ejecuta `terraform init -migrate-state`.

### ⚠️ Pasos Post-Despliegue

1.  **DNS**: Asegurar que los registros CNAME apuntan a la distribución.
2.  **Subida de Assets**: Subir archivos manualmente al bucket creado (Terraform no gestiona contenido).

    ```bash
    aws s3 cp cv-alejandro-vega.pdf s3://agevegacom-assets-private/assets/cv-alejandro-vega.pdf --profile terraform
    ```

---

## 🔧 Variables Importantes

| Variable             | Descripción                 | Valor por defecto           |
| :------------------- | :-------------------------- | :-------------------------- |
| `domain_name`        | Dominio principal del sitio | `agevega.com`               |
| `assets_bucket_name` | Nombre del bucket S3        | `agevegacom-assets-private` |

---

## 📤 Outputs

- `cloudfront_domain_name`: Dominio de la CDN.
- `assets_bucket_id`: Nombre del bucket creado.
- `assets_bucket_regional_domain_name`: Endpoint regional del bucket usado por CloudFront.
