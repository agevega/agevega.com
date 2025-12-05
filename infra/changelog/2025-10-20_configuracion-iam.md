# 🧩 2025-10-20 — Configuración inicial de IAM

### 🗂️ Descripción

Configuración de identidades y accesos iniciales (IAM) en la cuenta AWS recién creada.  
Objetivo: establecer un control de acceso seguro y segmentado entre el usuario administrador y el usuario técnico para Terraform.

---

### ⚙️ Acciones realizadas

#### 👤 Usuario `admin`

- Creado desde la consola AWS bajo _IAM → Users → Create user_.
- Nombre: `admin`.
- Se habilitó **acceso a la consola de administración AWS**.
- Contraseña inicial autogenerada (almacenada de forma segura).
- Política asignada: **`AdministratorAccess`**.
- Confirmado acceso a la consola.
- Verificado que el usuario puede visualizar y gestionar la **facturación**, gracias a la configuración previa de acceso IAM a Billing.

#### 🤖 Usuario `terraform`

- Creado desde _IAM → Users → Create user_.
- Nombre: `terraform`.
- Acceso: **solo programático (CLI)**, sin acceso a la consola.
- Política asignada: **`AdministratorAccess`** _(temporal, pendiente de restricción futura)_.
- Generadas **Access Keys** (Access Key ID y Secret Access Key).
- Claves almacenadas en lugar seguro para configuración posterior del proveedor Terraform.

---

### 🎯 Motivo

Separar funciones de administración humana y automatización:

- `admin` → gestión global de la infraestructura y consola.
- `terraform` → uso exclusivo por herramientas de IaC (Terraform, CLI, CI/CD).

Además:

- Evitar el uso del usuario raíz.
- Facilitar el control y la trazabilidad de operaciones.
