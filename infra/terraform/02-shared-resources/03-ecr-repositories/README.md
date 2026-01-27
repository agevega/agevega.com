# 03-ECR

Este módulo gestiona el **Elastic Container Registry (ECR)** donde se almacenan las imágenes Docker de la aplicación.
Incluye políticas de ciclo de vida automáticas para optimizar costes de almacenamiento.

---

## 🏛️ Recursos

1.  **ECR Repository**: `agevegacom-frontend` (por defecto).

    - **Escaneo:** Activado al subir imagen (`scan_on_push = true`).
    - **Mutabilidad:** Las etiquetas son mutables (permite sobrescribir `latest`).

2.  **Lifecycle Policy**:
    - **Regla:** Mantener solo las **últimas 10 imágenes**.
    - **Acción:** Expira y elimina automáticamente las imágenes antiguas para no pagar almacenamiento innecesario.

---

## 🚀 Uso rápido

```bash
cd infra/terraform/03-ECR
terraform init
terraform apply
```

---

## 🔧 Variables

| Variable          | Descripción                | Valor por defecto     |
| :---------------- | :------------------------- | :-------------------- |
| `repository_name` | Nombre del repositorio ECR | `agevegacom-frontend` |
| `aws_region`      | Región AWS                 | `eu-south-2`          |

---

## 📤 Outputs

Al finalizar, obtendrás la URL necesaria para hacer `docker push` en tus pipelines de CI/CD:

- `repository_url`: URL completa del repo (ej: `123456789012.dkr.ecr.eu-south-2.amazonaws.com/agevegacom-frontend`).
- `repository_arn`: ARN del recurso.
