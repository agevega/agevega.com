# 🤖 CI/CD - Agevega.com

Este directorio contiene los workflows de GitHub Actions que automatizan el ciclo de vida de la aplicación, desde el build hasta el despliegue en producción.

## 🔄 Pipeline de Despliegue

La automatización sigue un flujo encadenado ("Chain Reaction") para garantizar que solo las imágenes construidas exitosamente se desplieguen.

```mermaid
graph TD;
    A[Push Tag v*.*.*] -->|Triggers| B(00 Build & Push);
    B -->|Builds Docker Image| C{Success?};
    C -->|Yes| D[Push to ECR];
    D -->|Triggers via gh CLI| E(01 Deploy to EC2);
    E -->|SSH| F["Bastion Host (dev)"];
    F -->|Pull & Keep New Version| G[Update Container];
    E -->|AWS CLI| H[Invalidate CloudFront];
```

### 1. Build & Push (`00-generate-docker-image.yml`)

- **Trigger**: Push de un tag semántico (e.g., `v1.0.2`).
- **Acción**:
  1. Construye la imagen Docker del frontend (multi-arch).
  2. Publica la imagen en **AWS ECR** con el tag de versión y `latest`.
  3. **Dispara automáticamente** el siguiente workflow (`01-deploy-to-ec2`).

### 2. Deploy to EC2 (`01-deploy-to-ec2.yml`)

- **Trigger**: `workflow_dispatch` (generalmente invocado por el workflow anterior).
- **Acción**:
  1. **Dynamic Discovery**: Busca la IP pública del "Bastion Host" mediante tags de AWS (`Name=bastion-host`).
  2. **Remote Execution**: Conecta por SSH usando la clave privada almacenada en secretos.
  3. **Deploy**: Ejecuta el script `scripts/01_deploy_frontend.sh` en el servidor para rotar contenedores.
  4. **Cache Purge**: Invalida la caché de CloudFront para el entorno de desarrollo (`dev.agevega.com`).

## 🔐 Secretos Requeridos

Para que los pipelines funcionen, el repositorio debe tener configurados los siguientes **Secrets** y **Variables**:

| Nombre                  | Tipo     | Descripción                                               |
| :---------------------- | :------- | :-------------------------------------------------------- |
| `AWS_ACCESS_KEY_ID`     | Secret   | Credenciales de AWS IAM User (GitHubActions).             |
| `AWS_SECRET_ACCESS_KEY` | Secret   | Credenciales de AWS IAM User.                             |
| `EC2_SSH_KEY`           | Secret   | Clave privada `.pem` para acceder al Bastion.             |
| `AWS_REGION`            | Variable | Región de AWS (e.g., `eu-south-2`).                       |
| `ECR_REPOSITORY`        | Variable | Nombre del repositorio ECR (e.g., `agevegacom-frontend`). |

## 🛠 Ejecución Manual

Aunque el flujo es automático, puedes lanzar un despliegue manual desde la pestaña **Actions** de GitHub si necesitas:

- Redesplegar una versión antigua (Rollback).
- Forzar una actualización sin crear un tag nuevo.

Selecciona el workflow **"01 Deploy to EC2"**, pulsa "Run workflow" e introduce el tag de la imagen manual (e.g., `v1.0.1`).
