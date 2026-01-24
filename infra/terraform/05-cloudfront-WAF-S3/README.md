# 05-cloudfront-WAF-S3

Este módulo despliega la capa de entrega de contenido (CDN), seguridad (WAF) y almacenamiento de assets. Se ha diseñado de forma modular para optimizar costes y tiempos de despliegue, separando los recursos por región y ciclo de vida.

**Comportamiento Automático:**

- Si `02-waf` existe: Se asocia el Web ACL.
- Si `02-waf` no existe o fue destruido: Se despliega sin WAF.

> **⚠️ Importante**: Para que la detección automática funcione, el **archivo de estado** del módulo `02-waf` debe existir en S3.
> Si nunca has ejecutado el módulo `02-waf`, recibirás un error `No stored state was found`.
>
> **Solución para despliegue SIN WAF:**
>
> 1. Ejecuta `terraform apply` en `02-waf` (Crea el recurso).
> 2. Ejecuta `terraform destroy` en `02-waf` (Borra el recurso, pero deja el estado vacío).
> 3. Ejecuta `terraform apply` en `03-cloudfront`.
>
> Esto inicializa el estado remoto necesario para que CloudFront sepa que "no hay WAF".

---

## 🏛️ Arquitectura

El módulo se divide en 4 componentes secuenciales:

1.  **`00-s3-assets`** (Madrid):
    - Bucket S3 privado para alojar documentos (CV).
    - Configurado con bloqueo de acceso público y cifrado.
2.  **`01-acm-certificate`** (N. Virginia):
    - Certificado SSL/TLS público para CloudFront.
    - _Nota: CloudFront requiere certificados en `us-east-1`._
3.  **`02-waf`** (N. Virginia):
    - Firewall de aplicación web (Web ACL).
    - Protege la distribución de CloudFront.
    - _Nota: WAF para CloudFront debe estar en `us-east-1`._
4.  **`03-cloudfront`** (Madrid):
    - Distribución global de CloudFront.
    - Orquesta todos los anteriores: usa el certificado, sirve los assets del bucket y se protege con el WAF (opcional).

---

## 🚀 Guía de Despliegue Secuencial

Sigue este orden estricto:

### 1. Assets (`00-s3-assets`)

```bash
cd infra/terraform/05-cloudfront-WAF-S3/00-s3-assets
terraform init
terraform apply
```

### 2. Certificado (`01-acm-certificate`)

```bash
cd ../01-acm-certificate
terraform init
terraform apply
```

### 3. WAF (`02-waf`)

Este paso es **opcional**. Si quieres ahorrar costes, puedes saltarlo.

```bash
cd ../02-waf
terraform init
terraform apply
```

### 4. CloudFront (`03-cloudfront`)

La distribución detectará automáticamente la configuración del WAF.

```bash
cd ../03-cloudfront
terraform init
terraform apply
```

**Comportamiento:**

- Si `02-waf` **existe**: CloudFront se asocia al WAF automáticamente.
- Si `02-waf` **no existe** (o fue destruido): CloudFront se despliega sin WAF.

> **Nota**: Si nunca has inicializado `02-waf`, recuerda ejecutarlo y destruirlo una vez para crear el estado vacío (ver aviso arriba).

---

## ⚠️ Pasos Post-Despliegue

1.  **DNS**: Asegurar que los registros CNAME apuntan a la distribución (Output: `cloudfront_domain_name`).
2.  **Subida de Assets**:
    ```bash
    aws s3 cp cv-alejandro-vega.pdf s3://agevegacom-assets-private/assets/cv-alejandro-vega.pdf --profile terraform
    ```

---
