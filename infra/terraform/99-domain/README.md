# 99-domain

Módulo para la gestión centralizada de DNS (Route53).

## 🎯 Objetivo

Controlar la zona alojada (Hosted Zone) principal `agevega.com` y sus registros DNS asociados. Este módulo actúa como el "pegamento" final que conecta la infraestructura (CloudFront, ACM) con el mundo exterior.

## 🛠️ Arquitectura Dinámica

Este módulo **no tiene valores hardcodeados**. Lee el estado de otros módulos para configurarse automáticamente:

1.  **Bastion CloudFront (`04-bastion-host`)**: Para `dev.agevega.com`.
2.  **Prod CloudFront (`05-high-availability`)**: Para `agevega.com` y `www`.
3.  **ACM Certificates (`02-shared-resources`)**: Para autogenerar los registros CNAME de validación SSL.

## 📦 Recursos Gestionados

- **aws_route53_zone**: La zona principal `agevega.com`.
- **aws_route53_record (Alias A)**: Usamos Alias en lugar de CNAME para el vértice del dominio (Apex) y subdominios, por rendimiento y coste.
  - `agevega.com` -> CloudFront Prod
  - `www.agevega.com` -> CloudFront Prod
  - `dev.agevega.com` -> CloudFront Bastion
- **aws_route53_record (CNAME)**:
  - Validaciones de ACM (generadas dinámicamente mediante `for_each`).

## 🚀 Despliegue e Importación

### ⚠️ IMPORTANTE: Zona Existente

Como la zona ya existe en AWS (`Z08740021EDUKT5DV84WS`), debes **importarla** antes de aplicar:

```bash
cd infra/terraform/99-domain
terraform init
terraform import aws_route53_zone.main Z08740021EDUKT5DV84WS
```

### Aplicar Cambios

Una vez importada la zona, aplica el resto de la configuración. Terraform detectará que los registros ya existen (si los creaste a mano) o los creará si faltan.

```bash
terraform apply
```

## 📄 Outputs

- `zone_id`: El ID de la zona Route53.
- `dev_url`: URL del entorno Dev (`https://dev.agevega.com`).
