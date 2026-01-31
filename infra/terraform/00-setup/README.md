# 🛠️ 00-setup

Este módulo gestiona el **Bootstrap** inicial de la infraestructura y las herramientas de gobierno y auditoría. Establece los cimientos necesarios para que Terraform opere de forma segura.

![Architecture Diagram](../../diagrams/00-terraform-state-S3.png)

---

## 🏛️ Arquitectura

Este módulo prepara el entorno de AWS para ser gestionado por Terraform y establece controles de costes y seguridad.

- **Terraform Backend Remoto en S3**: Almacenamiento centralizado y bloqueo de estado para evitar condiciones de carrera.
- **Auditoría**: Registro de actividad de API (CloudTrail) e inventario de recursos (Config).
- **Control Financiero**: Alertas de presupuesto para evitar sorpresas en la facturación.

---

## 📂 Componentes (Submódulos)

### 1. [00-tf-backend](./00-tf-backend)

- **Función**: Bootstrap de IaC.
- **Recursos**:
  - `S3 Bucket`: Para guardar el archivo `terraform.tfstate` de cada submódulo.
  - `DynamoDB Table`: Para el bloqueo de estado (Locking).

### 2. [01-audit-logs](./01-audit-logs)

- **Función**: Compliance y Seguridad.
- **Recursos**:
  - `CloudTrail`: Trazas de auditoría de todas las llamadas a la API de AWS.
  - `AWS Config`: Historial de configuración y cambios en recursos.
  - `S3 Buckets`: Almacenamiento de logs.

### 3. [02-budgets](./02-budgets)

- **Función**: FinOps / Control de Costes.
- **Recursos**:
  - `AWS Budgets`: Presupuestos mensuales y diarios con alertas por email.

---

## 🚀 Guía de Despliegue

Este es el módulo "Huevo y la Gallina". El setup inicial se hace con estado local y luego se migra al remoto.

### 1. Bootstrap (00-tf-backend)

```bash
cd 00-tf-backend
terraform init
terraform apply
# Una vez creado, descomentar el bloque 'backend "s3"' en backend.tf y migrar:
terraform init -migrate-state
```

### 2. Auditoría (01-audit-logs)

```bash
cd ../01-audit-logs
terraform init
terraform apply
```

### 3. Presupuestos (02-budgets)

```bash
cd ../02-budgets
terraform init
terraform apply
```

---

## 🔧 Variables Clave

| Variable               | Descripción                    | Valor por Defecto            |
| :--------------------- | :----------------------------- | :--------------------------- |
| `bucket_name`          | Nombre del bucket de estado    | `agevegacom-terraform-state` |
| `dynamodb_table_name`  | Tabla para State Locking       | `terraform-state-lock`       |
| `region`               | Región principal de despliegue | `eu-south-2` (Spain)         |
| `monthly_budget_limit` | Límite de gasto mensual ($)    | `10`                         |
| `daily_budget_limit`   | Límite de gasto diario ($)     | `1`                          |
