# 99-domain

Módulo para la gestión centralizada de DNS (Route53).

## 🎯 Objetivo

Controlar la zona alojada (Hosted Zone) principal `agevega.com` y sus registros DNS asociados, permitiendo conectar los recursos de infraestructura (CloudFront, Load Balancers) con nombres de dominio amigables.

## 🛠️ Recursos

- **aws_route53_zone**: La zona principal del dominio.
- **aws_route53_record**: Registros DNS (CNAME, A, etc.).
  - `dev.agevega.com`: CNAME apuntando a la distribución CloudFront del entorno Bastion (leído dinámicamente desde el state remoto).

## 🚀 Despliegue e Importación

### ⚠️ IMPORTANTE: Si la zona ya existe en AWS

Si compraste el dominio en AWS o ya creaste la zona manualmente, **NO** ejecutes `terraform apply` directamente, o fallará intentando crear una zona duplicada.

Debes **importarla** al estado de Terraform primero:

1.  Obtén el **Zone ID** de tu consola AWS (Route53 -> Hosted zones).
2.  Ejecuta el comando de importación:

```bash
# Sintaxis: terraform import aws_route53_zone.main <ZONE_ID>
terraform import aws_route53_zone.main Z0123456789ABCDEF
```

### Despliegue Normal

Una vez importada la zona (o si es una zona completamente nueva):

```bash
terraform init
terraform plan
terraform apply
```

## 📄 Outputs

- `zone_id`: El ID de la zona Route53 gestionada.
- `dev_url`: La URL completa del entorno de desarrollo (`https://dev.agevega.com`).
