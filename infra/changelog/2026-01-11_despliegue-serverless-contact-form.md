# 🧩 2026-01-11 — Despliegue de Serverless Contact Form (Módulo 04)

### 🗂️ Descripción

Despliegue del módulo `04-lambda-SES` en `infra/terraform/04-lambda-SES/`. Este módulo implementa la lógica del formulario de contacto utilizando una arquitectura **Serverless** para minimizar costes y mantenimiento.

---

## ⚡ Serverless Architecture (Lambda + SES)

### ⚙️ Acciones realizadas

- **AWS Lambda**:
  - Función en **Python 3.11** para procesar los datos del formulario.
  - Arquitectura **ARM64 (Graviton2)** para mayor rendimiento y ahorro de costes (20% más barato).
  - Timeout ajustado a **5 segundos** y memoria de **128 MB**.
  - Configuración de logs en CloudWatch con retención de **1 día**.
- **Amazon API Gateway (HTTP API)**:
  - Endpoint público para recibir peticiones POST.
  - Configuración de **CORS** para permitir acceso solo desde `agevega.com` y `www.agevega.com`.
  - **Throttling** agresivo (1 RPS) para prevenir abusos y ataques DoS.
- **Amazon SES**:
  - Configuración de identidad de correo (`agevega@gmail.com`).
  - Despliegue **Multi-Región**: Identidad SES en `eu-west-1` (Irlanda) debido a la falta de disponibilidad en `eu-south-2` (España), integrada de forma transparente con la Lambda.
- **Seguridad**:
  - Roles IAM con principio de **Least Privilege**.

---

## 🎯 Motivo

- Habilitar funcionalidad dinámica (formulario de contacto) en una web estática (Astro).
- Evitar el uso de servidores permanentes para una funcionalidad de uso esporádico.
- Aprovechar el **Free Tier** de AWS para reducir el coste a cero.

---

## 💰 Coste estimado mensual

| Recurso             | Estimado mensual | Notas                                                               |
| :------------------ | :--------------- | :------------------------------------------------------------------ |
| **AWS Lambda**      | 0.00 €           | Cubierto por el Free Tier (1M peticiones/mes).                      |
| **API Gateway**     | 0.00 €           | Cubierto por el Free Tier (12 meses). Coste posterior despreciable. |
| **Amazon SES**      | ~0.00 €          | 0.10$ por cada 1000 correos (volumen esperado < 100).               |
| **CloudWatch Logs** | 0.00 €           | Retención de 1 día elimina costes de almacenamiento a largo plazo.  |

**Total estimado:** 0.00 €/mes
