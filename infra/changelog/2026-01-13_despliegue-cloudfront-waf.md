# 13/01/2026 — Despliegue de CloudFront y WAF (Módulo 05)

## 📝 Descripción

Implementación completa de la capa de distribución de contenido (CDN) y seguridad perimetral (WAF) para `agevega.com`. Se ha añadido el módulo `05-cloudfront-waf` y se ha refactorizado la seguridad del Bastion para un cierre total ("Hardening").

## 🏗 Arquitectura Final

- **CloudFront Distribution**: Punto de entrada global único.
  - **Origen**: IP Elástica del Bastion EC2 (`02-bastion-EC2`) vía DNS Público de AWS.
  - **SSL/TLS**: Terminación en el borde con certificado ACM (`*.agevega.com`).
  - **Protocolo Origen**: HTTP (Puerto 80).
    - _Nota_: Se utiliza HTTP hacia el origen para evitar fallos de validación SNI. La conexión viaja por la red interna segura de AWS.
- **AWS WAF**: Firewall de aplicación web asociado a CloudFront.
  - Reglas: `AWSManagedRulesCommonRuleSet` (OWASP Top 10).
- **Frontend (Nginx)**:
  - Configurado como `default_server`.
  - Escucha en puerto 80 sin redirección a HTTPS (para evitar bucles con CloudFront).

## 🔐 Seguridad (Hardening)

- **Módulo 02 Refactorizado**:
  - Se eliminaron las reglas de seguridad "inline" del recurso `aws_security_group`.
  - Se migraron a recursos modulares `aws_security_group_rule`.
- **Cierre de Puerto 80/443**:
  - Se eliminaron las reglas `ingress_http` e `ingress_https` que permitían acceso desde `0.0.0.0/0`.
  - **Acceso Directo Bloqueado**: Nadie puede acceder a la IP del servidor directamente.
  - **Acceso Permitido**: Solo IPs pertenecientes a la `Managed Prefix List` de CloudFront.

## ⚙️ Cambios realizados

### Infraestructura

1. **Nuevo Módulo `05-cloudfront-waf`**: CloudFront, WAF, ACM.
2. **Modificación `02-bastion-EC2`**:
   - Refactorización de Security Group.
   - Output nuevo: `eip_public_dns`.
   - Limpieza de reglas de acceso público.

### Frontend

1. **`nginx.conf`**:
   - Eliminado `return 301 https://...` en puerto 80.
   - Añadido `server_name _;` y `default_server` para capturar tráfico de proxy.

## 💰 Impacto en Costes

- **CloudFront**: Capa gratuita (1TB data out). Coste 0€.
- **WAF**: ~$5/mes (Web ACL) + $1/mes (Reglas). Estimado: ~6€/mes.
- **ACM**: Gratuito.
