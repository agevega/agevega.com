# 🧩 2025-10-26 — Configuración del backend remoto de Terraform (S3 + DynamoDB)

### 🗂️ Descripción

Despliegue del código contenido en `infra/terraform/00-setup/00-backend-S3`, encargado de configurar el almacenamiento remoto del estado de Terraform y su mecanismo de bloqueo mediante servicios gestionados de AWS.  
Con esta implementación, la infraestructura queda preparada para operar de forma segura y consistente con **estado centralizado, versionado y protegido frente a accesos no cifrados**.

---

## ☁️ AWS S3 – Estado remoto de Terraform

### ⚙️ Acciones realizadas

- Creado el bucket **`agevegacom-terraform-state`** en la región **`eu-south-2 (Madrid)`**.
- Configuración de seguridad aplicada:
  - **Bloqueo completo de acceso público** ✅
  - **Propiedad forzada al propietario (BucketOwnerEnforced)** ✅
  - **Versionado activado** ✅
  - **Cifrado SSE-AES256** habilitado por defecto ✅
  - **Política de denegación de tráfico no cifrado** (_DenyInsecureTransport_) ✅
- Definida **regla de ciclo de vida**:
  - Aborto de cargas multiparte tras **7 días**.
  - Conserva **las 10 versiones más recientes** y expira versiones no actuales tras **365 días**.
  - Transición de versiones no actuales a **GLACIER_IR** a los **30 días** y a **DEEP_ARCHIVE** a los **120 días**.
- Etiquetas aplicadas: `Name`, `Project`, `Owner`, `Role`, `IaC`.

---

## 🔒 AWS DynamoDB – Bloqueo de estado

### ⚙️ Acciones realizadas

- Creada la tabla **`terraform-state-lock`** con clave primaria `LockID` (tipo `S`).
- Modo de capacidad: **PAY_PER_REQUEST**.
- Configuración de seguridad:
  - **Cifrado SSE** habilitado ✅
  - **Protección frente a eliminación** (`deletion_protection_enabled = true`) ✅
  - **Recuperación a un punto en el tiempo (PITR)** habilitada ✅
- Etiquetas coherentes con el resto de la infraestructura (`Name`, `Project`, `Owner`, `Role`, `IaC`).

---

### 🎯 Motivo

- Desplegar el backend remoto de Terraform desde código IaC versionado.
- Centralizar el estado de Terraform en un bucket seguro y versionado.
- Evitar corrupciones o concurrencia mediante **bloqueo distribuido** en DynamoDB.
- Cumplir buenas prácticas de seguridad y resiliencia recomendadas por AWS para IaC.
