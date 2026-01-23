# 05-cloudfront-WAF-S3

Este módulo despliega la capa de entrega de contenido (CDN), seguridad (WAF) y almacenamiento de assets. Se ha diseñado de forma modular para optimizar costes y tiempos de despliegue, separando los recursos por región y ciclo de vida.

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

Si desplegaste el WAF en el paso anterior, obtén su ARN primero.

**Opción A: Sin WAF (Ahorro de costes)**

```bash
cd ../03-cloudfront
terraform init
terraform apply
```

**Opción B: Con WAF**

```bash
# Obtén el ARN del WAF (desde el output del módulo 02)
WAF_ARN=$(cd ../02-waf && terraform output -raw web_acl_arn)

cd ../03-cloudfront
terraform init
terraform apply -var="web_acl_arn=$WAF_ARN"
```

---

## ⚠️ Pasos Post-Despliegue

1.  **DNS**: Asegurar que los registros CNAME apuntan a la distribución (Output: `cloudfront_domain_name`).
2.  **Subida de Assets**:
    ```bash
    aws s3 cp cv-alejandro-vega.pdf s3://agevegacom-assets-private/assets/cv-alejandro-vega.pdf --profile terraform
    ```

---

## 🔧 Variables Importantes

### `03-cloudfront`

| Variable      | Descripción                                                  | Valor por defecto |
| :------------ | :----------------------------------------------------------- | :---------------- |
| `web_acl_arn` | ARN del WAF Web ACL. Dejar en `null` para desplegar sin WAF. | `null`            |
