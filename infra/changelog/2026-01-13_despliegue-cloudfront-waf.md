# 13/01/2026 — Despliegue de CloudFront y WAF (Módulo 05)

## 📝 Descripción

Implementación de la capa de distribución de contenido (CDN) y seguridad perimetral (WAF) para `agevega.com`. Se ha añadido el módulo `05-cloudfront-waf` a la infraestructura.

## 🏗 Arquitectura

- **CloudFront Distribution**: Punto de entrada global.
  - Origen: IP Elástica del Bastion EC2 (`02-bastion-EC2`).
  - SSL/TLS: Terminación en el borde con certificado ACM.
  - Protocolo Origen: HTTP (Puerto 80).
- **AWS WAF**: Firewall de aplicación web asociado a CloudFront.
  - Reglas: `AWSManagedRulesCommonRuleSet` (OWASP Top 10, protección básica).
- **ACM Certificate**: Certificado SSL wildcard (`*.agevega.com`) y raíz (`agevega.com`) en `us-east-1` (requerido por CloudFront).

## 🔐 Seguridad

- Se ha añadido una regla al Security Group del Bastion para permitir tráfico entrante en el puerto 80 **solo** desde la lista de prefijos de CloudFront (`com.amazonaws.global.cloudfront.origin-facing`).
- Esto permite, a futuro, eliminar la regla de acceso público `0.0.0.0/0` en el puerto 80 del Bastion para evitar accesos directos (bypass de WAF).

## ⚙️ Cambios realizados

1. Creación del directorio `infra/terraform/05-cloudfront-waf`.
2. Definición de recursos en Terraform:
   - `aws_acm_certificate`
   - `aws_wafv2_web_acl`
   - `aws_cloudfront_distribution`
   - `aws_security_group_rule`

## 💰 Impacto en Costes

- **CloudFront**: Capa gratuita (1TB data out). Coste 0€.
- **WAF**: ~$5/mes (Web ACL) + $1/mes (Reglas). Estimado: ~6€/mes.
- **ACM**: Gratuito.

## ⚠️ Acciones Manuales Requeridas

Tras realizar el `terraform apply`:

1. **Validación DNS**: Añadir los registros CNAME proporcionados en el output `acm_certificate_validation_options` a la zona DNS de `agevega.com`.
2. **Apuntar DNS**: Actualizar el registro A/CNAME principal de `agevega.com` para que apunte al `cloudfront_domain_name`.
