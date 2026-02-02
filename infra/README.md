# 🏗️ Infraestructura - Agevega.com

Documentación técnica de la infraestructura como código (IaC) para **agevega.com**. Este directorio contiene todo el código Terraform modularizado para desplegar una arquitectura segura, escalable y optimizada en costes en AWS.

---

## 🏛️ Arquitectura Global

La infraestructura sigue una filosofía **Cloud Native** y **Serverless First** donde sea posible, priorizando la seguridad y la reducción de costes operativos.

### Principios de Diseño

- **Inmutabilidad**: Toda la infraestructura es gestionada via Terraform (`infra/terraform`). No se permiten cambios manuales.
- **Seguridad**:
  - **WAF**: Reglas gestionadas de AWS protegiendo CloudFront.
  - **CloudFront + OAC**: Distribución global de contenido estático desde S3 privado.
  - **EC2 Aislado**: Instancias en subredes privadas, accesibles solo via Bastion (SSH) o ALB (HTTP).
- **Eficiencia de Costes**:
  - **ARM64 (Graviton)**: Uso exclusivo de procesadores Graviton (`t4g.*`) en cómputo y Lambda.
  - **Spot Instances**: Entornos de alta disponibilidad sobre instancias Spot.

---

## 📂 Estructura de Módulos

La infraestructura se organiza en módulos numerados secuencialmente según su orden de despliegue.

| Módulo                                                         | Descripción              | Componentes Clave                                                      |
| :------------------------------------------------------------- | :----------------------- | :--------------------------------------------------------------------- |
| **[00-setup](./terraform/00-setup)**                           | **IaC & Gobierno**       | Backend S3/DynamoDB, CloudTrail, AWS Config, Budgets.                  |
| **[01-networking](./terraform/01-networking)**                 | **Recursos de Red**      | VPC (3-Tier), Subnets, NAT (Opcional), VPC Endpoints.                  |
| **[02-shared-resources](./terraform/02-shared-resources)**     | **Recursos Compartidos** | SSH Keys, ECR, S3 Assets.                                              |
| **[03-backend-serverless](./terraform/03-backend-serverless)** | **Serverless Backend**   | Lambda (Python), API Gateway, SES.                                     |
| **[04-bastion-host](./terraform/04-bastion-host)**             | **Bastion SSH**          | EC2 Bastion, Elastic IP, Security Groups, WAF, CloudFront, DNS Record. |
| **[05-high-availability](./terraform/05-high-availability)**   | **Alta Disponibilidad**  | ASG (Spot), ALB, CloudFront, WAF, Auto-Scaling, DNS Record.            |
| **[99-domain](./terraform/99-domain)**                         | **Gestión de Dominio**   | Hosted Zones (Route53), ACM Certificates, DNS Validation.              |

---

## 🚀 Getting Started

### Prerrequisitos

- **Terraform** >= 1.5.0
- **AWS CLI** configurado con perfil `terraform` o variable `AWS_PROFILE`.

### Flujo de Trabajo

Cada módulo es independiente pero depende del estado remoto de los anteriores.

1. Navegar al directorio del módulo/submódulo:
   ```bash
   cd infra/terraform/<module>/<submodule>
   ```
2. Inicializar Terraform:
   ```bash
   terraform init
   ```
3. Planificar y aplicar:
   ```bash
   terraform apply
   ```

---

## 🔒 Gestión del Estado

El estado de Terraform se almacena de forma remota y segura:

- **Bucket**: `agevegacom-terraform-state` (Encriptado, Versionado).
- **Locking**: Tabla DynamoDB `terraform-state-lock`.

---

## 🗓️ Cronología general

### 18/10/2025 — Creación de la cuenta AWS

- Alta de nueva cuenta AWS (`agevega.com@gmail.com`)
- Activación de plan de pago estándar
- Configuración de MFA para el usuario raíz
- Activación del acceso a **facturación y costes** para usuarios IAM
- Cambio del idioma de la consola a **English (US)**
- Configuración de la **moneda de visualización y facturación en euros (EUR)**
- Creación del presupuesto global **“My 10$ Budget”** con alertas al 10 %, 50 %, 100 % y 200 %
- Creación del presupuesto global **“My Daily 1$ Budget”** con alertas al 50 %, 100 %, 200 %, 500 % y 1000 %
  ➡️ [Detalles](changelog/2025-10-18_creacion-cuenta.md)

### 20/10/2025 — Configuración inicial de IAM

- Creación del usuario `admin` con acceso a la consola y permisos `AdministratorAccess`
- Creación del usuario `terraform` con acceso programático (CLI) y permisos `AdministratorAccess`  
  ➡️ [Detalles](changelog/2025-10-20_configuracion-iam.md)

### 24/10/2025 — Activación de auditoría y registro de configuración

- Habilitación de **AWS CloudTrail** con validación de logs y almacenamiento en S3 (`cloudtrail-logs-agevegacom`).
- Habilitación de **AWS Config** con grabación continua de todos los recursos y entrega en S3 (`aws-config-logs-agevegacom`).
  ➡️ [Detalles](changelog/2025-10-24_auditoria-y-configuracion-logs.md)

### 26/10/2025 — Configuración del backend remoto de Terraform (S3 + DynamoDB)

- Despliegue del código en `infra/terraform/00-terraform-state-S3` para configurar el backend remoto de Terraform.
- Creación del **bucket S3** `terraform-state-agevegacom` en `eu-south-2` para el estado remoto.
- Activación de **versionado**, **cifrado SSE-AES256**, **bloqueo de acceso público** y **propiedad forzada al propietario**.
- Aplicación de política **DenyInsecureTransport** y regla de ciclo de vida con transición a **GLACIER_IR (30 d)** y **DEEP_ARCHIVE (120 d)**.
- Creación de la **tabla DynamoDB** `terraform-state-lock` para bloqueo de estado, con **SSE**, **PITR** y **protección contra borrado** habilitados.
- Registro del par de claves de pruebas `${var.resource_prefix}-test-keypair`
  ➡️ [Detalles](changelog/2025-10-26_configuracion-terraform-state.md)

### 01/11/2025 — Despliegue de red (VPC, subredes y componentes base)

- Despliegue del módulo `01-networking` en `infra/terraform/01-networking/`.
- Creación de la **VPC principal** `agevegacom-vpc` en `eu-south-2` (Madrid), con bloque CIDR `10.0.0.0/16`.
- Definición de **3 zonas de disponibilidad**: `eu-south-2a`, `eu-south-2b`, `eu-south-2c`.
- Creación de **3 subredes públicas**, **3 subredes privadas** y **3 subredes de bases de datos**, todas etiquetadas y distribuidas equitativamente.
- Habilitación de **DNS hostnames** y **DNS support** en la VPC.
- Creación de la **Internet Gateway** y asociación con la VPC.
- Creación de **tablas de rutas** separadas para subredes públicas, privadas y de bases de datos.
- Se documenta NAT Gateway como mejora futura (no desplegado para mantener el presupuesto 5–10 €).
- Definición de **etiquetado uniforme** (`Environment`, `Project`, `Owner`, etc.) en todos los recursos.  
  ➡️ [Detalles](changelog/2025-11-01_despliegue-red-vpc.md)

### 06/12/2025 — Despliegue del Bastion EC2 (Módulo 02)

- Despliegue del código en `infra/terraform/02-bastion-EC2` con arquitectura dividida.
- **00-security**: Despliegue de recursos persistentes (IP Elástica, Security Groups, Key Pair).
- **01-instance**: Despliegue de recursos efímeros (Instancia EC2 t3.micro) para optimización de costes.
- Configuración de **Docker** y **Git** automática mediante User Data.
- Habilitación de tráfico **HTTP/HTTPS** y **SSH** seguro.
- Integración de clave SSH local existente.
  ➡️ [Detalles](changelog/2025-12-06_despliegue-bastion-ec2.md)

### 07/12/2025 — Despliegue de repositorio ECR (Módulo 03)

- Despliegue del código en `infra/terraform/03-ECR` para gestión de imágenes Docker.
- Creación de repositorio **ECR** `agevegacom-frontend` con escaneo de seguridad y políticas de ciclo de vida.
- Integración con el sistema de despliegue mediante Terraform backend S3.
  ➡️ [Detalles](changelog/2025-12-07_despliegue-ecr.md)

### 11/01/2026 — Despliegue de Serverless Contact Form (Módulo 04)

- Despliegue del módulo `04-lambda-SES` para gestionar el formulario de contacto.
- Arquitectura **Serverless** (Lambda Python + API Gateway) para coste mínimo.
- Configuración **Multi-Región** para SES (Irlanda) integrada con infraestructura en España.
- Optimización de costes (ARM64, Logs 1 día, Throttling).
  ➡️ [Detalles](changelog/2026-01-11_despliegue-serverless-contact-form.md)

### 12/01/2026 — Optimización de Costes EC2 (Migración a ARM64)

- Migración del Bastion Host a instancia **`t4g.nano`** (Graviton2).
- Actualización de AMI y workflows de CI/CD para soporte **Multi-Arch (ARM64/AMD64)**.
- Reducción de costes operativos al mínimo (~3€/mes).
  ➡️ [Detalles](changelog/2026-01-12_optimizacion-ec2-arm.md)

### 13/01/2026 — Despliegue de CloudFront y WAF (Módulo 05)

- Despliegue del módulo `05-cloudfront-waf`.
- Implementación de **CloudFront** como CDN global con terminación SSL/TLS.
- Implementación de **AWS WAF** (Desactivado para ahorro de costes) con reglas Core de AWS para seguridad perimetral.
- Integración con EC2 a través de Security Group dinámico (Prefix List).
  ➡️ [Detalles](changelog/2026-01-13_despliegue-cloudfront-waf.md)

### 14/01/2026 — Consolidación de Assets y CloudFront (Módulo 05)

- Fusión de S3 Assets dentro del módulo de CloudFront (`05-cloudfront-WAF-S3`).
- Implementación de **OAC (Origin Access Control)** para acceso seguro a documentos privados (CV).
  ➡️ [Detalles](changelog/2026-01-14_consolidacion-s3-cloudfront.md)

### 22/01/2026 — Refactorización Networking y Auditoría

- División de `01-networking` en submódulos (`vpc-core`, `nat-gateway`, `vpc-endpoints`) para gestión de costes.
- Corrección integral de documentación y dependencias.
  ➡️ [Detalles](changelog/2026-01-22_refactorizacion-networking-y-doc.md)

### 23/01/2026 — Refactorización Bastion EC2 (Módulo 02)

- Refactorización del módulo `02-bastion-EC2` en 4 submódulos (`security`, `ssh-key`, `eip`, `instance`) para granularidad total.
- Restricción de acceso SSH a IP personal por defecto.
  ➡️ [Detalles](changelog/2026-01-23_refactorizacion-bastion.md)

### 24/01/2026 — Refactorización CloudFront (Módulo 05)

- Refactorización de `05-cloudfront-WAF-S3` en 4 submódulos secuenciales.
- Optimización regional: S3/CloudFront en Madrid (eu-south-2), ACM/WAF en N. Virginia (us-east-1).
- WAF opcional ("Plug & Play") para ahorro de costes.
  ➡️ [Detalles](changelog/2026-01-24_refactorizacion-cloudfront.md)

### 02/02/2026 — Refactorización Dominios y Estandarización

- Creación del nuevo módulo raíz `99-domain` para centralizar la gestión de DNS y Certificados.
- Movimiento de `02-shared-resources` a `99-domain` (Certificados) y reordenamiento interno.
- Creación de submodulos `dns-record` en `04-bastion` y `05-ha` para registros finales.
- Auditoría completa de `tags` y estandarización de nombres en todos los submódulos.
  ➡️ [Detalles](changelog/2026-02-02_refactorizacion-dominios.md)
