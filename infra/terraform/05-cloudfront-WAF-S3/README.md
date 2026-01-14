# 05-cloudfront-waf

Este módulo despliega la capa de distribución y seguridad perimetral para `agevega.com`.

<!-- ![Architecture Diagram](../../diagrams/05-cloudfront-waf.png) -->

---

## 🏛️ Arquitectura

### Componentes Principales

1.  **CloudFront Distribution**:

    - Actúa como punto de entrada único global.
    - **Origen**: IP Elástica del Bastion EC2 (vía DNS Público).
    - **Protocolo Viewer**: HTTPS forzado (`redirect-to-https`).
    - **Protocolo Origin**: HTTP (Puerto 80).
      - _Nota_: Se utiliza `http-only` hacia el origen para evitar conflictos de validación de certificados SNI. La conexión viaja por la red interna segura de AWS.

2.  **AWS WAF (Opcional - DESACTIVADO)**:

    - _Desactivado actualmente para ahorro de costes (~6€/mes)._
    - Asociado a la distribución de CloudFront.
    - Utiliza el conjunto de reglas gestionadas `AWSManagedRulesCommonRuleSet` (OWASP Top 10, protección contra exploits comunes).

3.  **ACM Certificate**:
    - Certificado SSL/TLS público para `agevega.com` y `*.agevega.com`.
    - Validado mediante DNS en la región `us-east-1` (obligatorio para CloudFront).

---

## 🚀 Guía de Despliegue

```bash
cd infra/terraform/05-cloudfront-waf
terraform init
terraform apply
```

### ⚠️ Pasos Post-Despliegue

1.  **Validación DNS**: Añadir los registros CNAME indicados en el output `acm_certificate_validation_options` a tu proveedor de DNS.
2.  **Apuntar Dominio**: Crear un registro CNAME/ALIAS en tu DNS para apuntar `agevega.com` hacia el dominio de CloudFront (`xxxxx.cloudfront.net`).

---

## 🔧 Variables Importantes

| Variable      | Descripción                 | Valor por defecto |
| :------------ | :-------------------------- | :---------------- |
| `domain_name` | Dominio principal del sitio | `agevega.com`     |
| `environment` | Etiqueta de entorno         | `lab`             |

---

## 📤 Outputs

- `cloudfront_domain_name`: Dominio asignado por AWS (ej: `d1234.cloudfront.net`).
- `cloudfront_distribution_id`: ID de la distribución.
- `acm_certificate_validation_options`: Registros DNS necesarios para validar el certificado SSL.
