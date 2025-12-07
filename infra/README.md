# 🧱 Infraestructura – agevegacom

Registro cronológico de la configuración y mantenimiento de la infraestructura en AWS para el proyecto **agevegacom**.

Este documento actúa como índice general de todas las operaciones y cambios realizados, con enlaces a las entradas detalladas del registro diario en la carpeta `changelog/`.

---

## 📘 Estructura del directorio

```bash
infra/
├── changelog/
│   ├── 2025-10-18_creacion-cuenta.md
│   └── 2025-10-18_configuracion-iam.md
│   └── 2025-10-24_auditoria-y-configuracion-logs.md
│   └── 2025-10-26_configuracion-terraform-state.md
│   └── 2025-11-01_despliegue-red-vpc.md
├── terraform/
│   ├── 00-terraform-state-S3/
│   ├── 01-networking/
│   ├── 02-bastion-EC2/
│   ├── 03-ECR/
└── README.md
```

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
