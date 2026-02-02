# 99-domain

Modulo para la gestión centralizada de DNS (Route53), dividido en submódulos para resolver dependencias circulares (Chicken & Egg) con certificados ACM y CloudFront.

## 📂 Estructura

```text
99-domain/
├── 00-dns-zone       # Crea la Hosted Zone (agevega.com)
├── 01-acm-validation # Lee ACM (02) y crea registros de validación
└── 02-dns-records    # Lee CloudFronts (04, 05) y crea registros Alias A
```

## 🚀 Despliegue Secuencial (Chicken/Egg Fix)

Debes desplegar en este orden específico para resolver las dependencias:

1.  **00-dns-zone**:
    - Crea la zona para que existan los Name Servers.
    - `terraform import aws_route53_zone.main Z08740021EDUKT5DV84WS` (Si ya existe).
    - `terraform apply`

2.  **02-shared-resources/01-acm-certificates** (Fuera de este módulo):
    - Crea el certificado. Se quedará en "Pending Validation" hasta el paso 3.
    - `terraform apply`

3.  **01-acm-validation**:
    - Lee el certificado pendiente y crea los CNAME de validación en la zona del paso 1.
    - `terraform apply`
    - **Espera** a que el certificado pase a "Issued".

4.  **04-bastion-host/04-cloudfront** (y 05):
    - Ahora que el certificado es válido, CloudFront puede usarlo.
    - `terraform apply`

5.  **02-dns-records**:
    - Ahora que CloudFront existe, podemos crear los Alias A (`dev`, `www`, `root`).
    - `terraform apply`
