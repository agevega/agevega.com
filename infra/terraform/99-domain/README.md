# 99-domain

Modulo para la gestión centralizada de DNS (Route53).

## 📂 Estructura

```text
99-domain/
├── 00-dns-zone       # Crea la Hosted Zone (agevega.com)
├── 01-acm-validation # Lee ACM (02) y crea registros de validación
```

> **Nota**: Los registros DNS de aplicación (`A` Alias) se han movido a sus respectivos módulos para permitir despliegues independientes:
>
> - `dev.agevega.com` -> `04-bastion-host/05-dns-record`
> - `agevega.com`, `www` -> `05-high-availability/04-dns-record`

## 🚀 Despliegue Secuencial

Orden de ejecución recomendado para evitar dependencias circulares:

1.  **00-dns-zone**:
    - Crea la zona base.
    - `terraform import aws_route53_zone.main Z08740021EDUKT5DV84WS` (Si ya existe).
    - `terraform apply`

2.  **02-shared-resources/01-acm-certificates**:
    - Crea el certificado SSL (Estado: Pending Validation).
    - `terraform apply`

3.  **01-acm-validation**:
    - Crea los CNAMEs para validar el certificado.
    - `terraform apply` -> Esperar a "Issued".

4.  **04-bastion-host**:
    - ... `04-cloudfront` (Crea la distribución usando el cert validado).
    - `05-dns-record` (Crea el registro `dev` apuntando a la distribución).

5.  **05-high-availability**:
    - ... `03-cloudfront` (Crea la distribución de Prod).
    - `04-dns-record` (Crea los registros `root` y `www`).
