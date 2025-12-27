# 🧩 2025-10-27 — Activación de auditoría y registro de configuración (CloudTrail + AWS Config)

### 🗂️ Descripción

Despliegue del código contenido en `infra/terraform/00-setup/01-init-config`, encargado de habilitar los servicios **AWS CloudTrail** y **AWS Config** para registrar toda la actividad y los cambios de configuración dentro de la cuenta AWS (`agevega.com@gmail.com`).  
Con esta configuración, el entorno queda preparado para auditoría completa, trazabilidad de eventos y control de configuración en tiempo real.

---

## 🧾 AWS CloudTrail

### ⚙️ Acciones realizadas

- Creado un **Trail multirregional** con nombre:  
  `agevegacom-trail`
- Región principal: **eu-south-2 (España)**.
- Activado registro de eventos en **todas las regiones**.
- Bucket S3 asociado:  
  `cloudtrail-logs-agevegacom`
- Configuración de seguridad:
  - Bloqueo de acceso público ✅
  - ACLs deshabilitadas ✅
  - Cifrado SSE-S3 activo ✅
- Activada la **validación de archivos de registro** para garantizar la integridad de los logs.
- Confirmado envío de archivos al bucket:  
  `s3://cloudtrail-logs-agevegacom/AWSLogs/332327025453/`
- No configuradas notificaciones SNS ni integración con CloudWatch Logs.

---

### 🎯 Motivo

- Registrar todas las acciones ejecutadas por usuarios o servicios dentro de la cuenta.
- Garantizar trazabilidad total y auditoría de seguridad.
- Cumplir las mejores prácticas de gobierno recomendadas por AWS.

---

### 💰 Coste estimado CloudTrail

| Concepto                      | Estimado mensual |
| ----------------------------- | ---------------- |
| CloudTrail (1 trail gratuito) | 0 €              |
| Almacenamiento S3 (logs)      | ~0,05 €          |
| Validación de archivos        | 0 €              |

**Total aproximado:** < 0,10 €/mes

---

## 🧩 AWS Config

### ⚙️ Acciones realizadas

- Servicio habilitado en la región **eu-south-2 (España)**.
- Grabación configurada en modo **continuo** para **todos los tipos de recursos**.
- Activada la opción **incluir recursos globales** (IAM, CloudFront, etc.).
- Bucket S3 de entrega creado:  
  `aws-config-logs-agevegacom`
- Propiedades del bucket:
  - Bloqueo de acceso público ✅
  - ACLs deshabilitadas ✅
  - Cifrado SSE-S3 por defecto ✅
- Rol de servicio generado automáticamente:  
  `AWSServiceRoleForConfig`
- Retención de datos: **90 días**.
- Sin reglas de configuración activas.
- Sin notificaciones SNS.

---

### 🎯 Motivo

- Registrar el estado y la evolución de los recursos en AWS.
- Detectar cambios no planificados y mantener histórico de configuraciones.
- Asegurar visibilidad continua de la infraestructura para auditoría o investigación futura.

---

### 💰 Coste estimado AWS Config

| Concepto                                   | Estimado mensual |
| ------------------------------------------ | ---------------- |
| Grabación de configuración (~200 recursos) | ~0,55 €          |
| Almacenamiento S3 (snapshots JSON)         | ~0,05 €          |
| Reglas de evaluación (0 activas)           | 0 €              |

**Total aproximado:** ~0,60 €/mes

---

## 📊 Resumen general

| Servicio       | Estado                     | Región     | Bucket                       | Coste estimado |
| -------------- | -------------------------- | ---------- | ---------------------------- | -------------- |
| **CloudTrail** | Activo + Validación ON     | eu-south-2 | `cloudtrail-logs-agevegacom` | ~0,05 €        |
| **AWS Config** | Activo + Retención 90 días | eu-south-2 | `aws-config-logs-agevegacom` | ~0,60 €        |

**Coste total estimado mensual:** ~0,65 €
