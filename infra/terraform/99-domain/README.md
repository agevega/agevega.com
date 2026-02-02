# 🌍 99-domain

Este módulo centraliza la gestión de la identidad del dominio (`agevega.com`) y la seguridad (SSL/TLS).  
Es el punto de partida de la infraestructura pública, estableciendo la zona DNS y los certificados necesarios para el tráfico HTTPS.

---

## 🏛️ Arquitectura

La gestión del dominio se desacopla para evitar dependencias circulares y permitir que múltiples entornos (Dev/Prod) compartan la misma identidad base.

- **DNS Autoritativo**: Route53 Hosted Zone gestiona todos los registros del dominio.
- **Seguridad en Tránsito**: Certificados ACM públicos desplegados en `us-east-1` para compatibilidad global con CloudFront.
- **Validación Automática**: Validación de certificados mediante registros DNS CNAME, gestionada enteramente como código.

---

## 📂 Componentes (Submódulos)

### 1. [00-dns-zone](./00-dns-zone)

- **Función**: Zona DNS Base.
- **Recursos**: Route53 Hosted Zone (`agevega.com`).
- **Nota**: Si el dominio fue registrado manualmente, se debe importar la zona existente.

### 2. [01-acm-certificate](./01-acm-certificate)

- **Función**: Identidad SSL/TLS.
- **Recursos**: AWS Certificate Manager (ACM) Certificate.
- **Región**: `us-east-1` (Requerido por CloudFront).

### 3. [02-acm-validation](./02-acm-validation)

- **Función**: Validación de Dominio.
- **Recursos**: Route53 Records (CNAME) para completar el desafío de validación de ACM.

---

## 🚀 Guía de Despliegue

Debido a la naturaleza de la validación DNS, el orden de despliegue es estricto.

### 1. Hosted Zone (00-dns-zone)

```bash
cd 00-dns-zone
terraform init
# Si la zona ya existe en AWS (creada manualmente):
terraform import aws_route53_zone.main <HOSTED_ZONE_ID>
terraform apply
```

### 2. Certificado SSL (01-acm-certificate)

```bash
cd ../01-acm-certificate
terraform init
terraform apply
```

_El certificado quedará en estado `Pending Validation`._

### 3. Validación (02-acm-validation)

```bash
cd ../02-acm-validation
terraform init
terraform apply
```

_Terraform esperará hasta que el certificado cambie a estado `Issued` (normalmente < 5 min)._

---

## 🔧 Variables Clave

| Variable      | Descripción                  | Valor por Defecto |
| :------------ | :--------------------------- | :---------------- |
| `domain_name` | Dominio raíz del proyecto    | `agevega.com`     |
| `aws_region`  | Región para la zona DNS      | `eu-south-2`      |
| `common_tags` | Etiquetas estándar (Project) | `agevegacom`      |

---

## ⚡ Optimización y Costes

- **Certificados Gratuitos**: Los certificados públicos de ACM son **gratuitos** y se renuevan automáticamente, eliminando costes de mantenimiento y compra de SSLs de terceros.
- **DNS Gestionado**: Route53 garantiza SLA del 100% para resolución DNS, crítico para la disponibilidad de toda la plataforma.
