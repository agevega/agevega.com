# Refactorización del Módulo CloudFront (05-cloudfront-WAF-S3)

**Fecha:** 24/01/2026  
**Autor:** Terraform  
**Módulos afectados:** `05-cloudfront-WAF-S3`

---

## 📝 Descripción del cambio

Se ha refactorizado radicalmente el módulo `05-cloudfront-WAF-S3` para optimizar costes, tiempos de despliegue y separar responsabilidades regionales.

La nueva arquitectura divide el despliegue en 4 submódulos secuenciales:

1.  **`00-s3-assets`** (Madrid): Almacenamiento de assets.
2.  **`01-acm-certificate`** (N. Virginia): Gestión de certificados globales.
3.  **`02-waf`** (N. Virginia): Firewall de capa 7 (WAF) desacoplado.
4.  **`03-cloudfront`** (Madrid): Orquestador global.

## 🏗️ Cambios en Infraestructura

### Desacoplamiento WAF

La principal mejora es la capacidad de "Plug & Play" del WAF.

- El módulo `02-waf` contiene la definición de reglas. Puede crearse o destruirse independientemente.
- El módulo `02-waf` contiene la definición de reglas. Puede crearse o destruirse independientemente.
- El módulo `03-cloudfront` tiene lógica de auto-descubrimiento. Detecta si el WAF existe y lo asocia automáticamente. Incluye una variable `enable_waf` para permitir la desvinculación manual.

### Nuevo Árbol de Directorios

```plaintext
05-cloudfront-WAF-S3/
├── 00-s3-assets/         # S3 Bucket (eu-south-2)
├── 01-acm-certificate/   # ACM (us-east-1)
├── 02-waf/               # WAF WebACL (us-east-1)
└── 03-cloudfront/        # Distribution (eu-south-2)
```
