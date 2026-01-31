# 03-backend-serverless (00-contact-api)

Este módulo implementa el backend **Serverless** para el formulario de contacto del sitio web. Utiliza AWS Lambda y Amazon SES para procesar correos electrónicos sin necesidad de servidores dedicados.

---

## 🏛️ Arquitectura

- **AWS Lambda (Python 3.11)**: Procesa las peticiones POST, valida los datos y conecta con SES.
  - Arquitectura: `arm64` (Graviton2) para optimización de costes.
  - Logs: CloudWatch con retención de 1 día.
- **Amazon API Gateway (HTTP API)**: Expone el endpoint público `/send` con protección CORS y Throttling (1 RPS).
- **Amazon SES**: Servicio de envío de emails.
  - **Configuración Multi-Región**: Debido a la falta de SES en `eu-south-2` (España), la identidad se despliega en `eu-west-1` (Irlanda).

---

## 🚀 Guía de Despliegue

```bash
cd infra/terraform/03-backend-serverless/00-contact-api
terraform init
terraform apply
```

Tras el despliegue, obtendrás la URL del endpoint en el output `api_endpoint`.

---

## 🔧 Variables Importantes

| Variable          | Descripción                   | Valor por defecto   |
| :---------------- | :---------------------------- | :------------------ |
| `sender_email`    | Email remitente (verificado)  | `agevega@gmail.com` |
| `recipient_email` | Email destino                 | `agevega@gmail.com` |
| `ses_region`      | Región para SES (ej: Ireland) | `eu-west-1`         |

---

## 📤 Outputs

- **api_endpoint**: URL completa para configurar en el frontend.
- **lambda_function_name**: Nombre del recurso Lambda desplegado.
