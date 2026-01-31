# ⚡ 03-backend-serverless

Este módulo implementa el backend **Serverless** para el formulario de contacto del sitio web.

---

## 🏛️ Arquitectura

Diseñado para escalar a cero (coste cero cuando no se usa) y manejar picos de tráfico sin gestión de servidores.

- **Cómputo**: AWS Lambda (Python 3.11) sobre arquitectura ARM64.
- **API**: API Gateway v2 (HTTP API) como frontend público.
- **Email**: Amazon SES para envío transaccional.
- **Multi-Región**: Lambda en `eu-south-2` (España) conecta con SES en `eu-west-1` (Irlanda) debido a disponibilidad de servicio.

---

## 📂 Componentes (Submódulos)

### 1. [00-contact-api](./00-contact-api)

- **Función**: API de Contacto.
- **Recursos**:
  - `Lambda Function`: Procesa el formulario.
  - `API Gateway`: Endpoint HTTP `POST /send`.
  - `SES Identity`: Validación de email remitente.

---

## 🚀 Guía de Despliegue

### 1. Contact API

```bash
cd 00-contact-api
terraform init
terraform apply
```

Tras el despliegue, obtendrás la URL del endpoint en el output `api_endpoint`.

---

## 🔧 Variables Clave

| Variable          | Descripción                            | Valor por Defecto   |
| :---------------- | :------------------------------------- | :------------------ |
| `sender_email`    | Email verificado que envía los correos | `agevega@gmail.com` |
| `recipient_email` | Email donde llegan los contactos       | `agevega@gmail.com` |
| `ses_region`      | Región donde opera SES                 | `eu-west-1`         |

---

## ⚡ Optimización y Costes

- **ARM64 (Graviton2)**: Las funciones Lambda configuradas con arquitectura `arm64` tienen un rendimiento precio/rendimiento hasta un 34% mejor que x86.
- **Throttling**: Configurado a nivel de API Gateway para limitar a 1 petición por segundo (burst 2), protegiendo contra ataques de denegación de servicio y costes de invocación masiva.
