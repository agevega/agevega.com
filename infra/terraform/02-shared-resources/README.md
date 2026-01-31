# 📦 02-shared-resources

Este módulo centraliza recursos compartidos que son prerequisitos para otros módulos o que tienen un ciclo de vida global independiente.

---

## 🏛️ Arquitectura

Los recursos aquí definidos son consumidos tanto por el entorno de desarrollo (Bastion) como por el de producción (HA).

- **Gestión de Identidad (SSH)**: Clave pública centralizada para acceso EC2.
- **Seguridad (TLS)**: Certificados ACM validados por DNS en `us-east-1` (requerido por CloudFront).
- **Contenido Estático**: Buckets S3 privados accesibles solo vía OAC (CloudFront).
- **Contenedores**: Repositorios ECR con políticas de ciclo de vida automáticas.

---

## 📂 Componentes (Submódulos)

### 1. [00-ssh-keys](./00-ssh-keys)

- **Función**: Acceso administrativo.
- **Recursos**: Key Pair de EC2 (`bastion-key`).

### 2. [01-acm-certificates](./01-acm-certificates)

- **Función**: Cifrado en tránsito (HTTPS).
- **Recursos**: Certificado ACM público.
- **Nota**: Desplegado en `us-east-1` (Global).

### 3. [02-s3-buckets](./02-s3-buckets)

- **Función**: Almacenamiento de assets (CV, imágenes).
- **Recursos**: Bucket S3 privado con encriptación AES256.

### 4. [03-ecr-repositories](./03-ecr-repositories)

- **Función**: Registro de imágenes Docker.
- **Recursos**: ECR Repository con escaneo de vulnerabilidades.

---

## 🚀 Guía de Despliegue

Debido a la independencia de estos recursos, el orden dentro del módulo no es estricto, pero se recomienda seguir la numeración:

### 1. SSH Keys

```bash
cd 00-ssh-keys
terraform init
terraform apply
```

### 2. Certificados CAS (Tarda unos minutos)

```bash
cd ../01-acm-certificates
terraform init
terraform apply
```

### 3. S3 Assets

```bash
cd ../02-s3-buckets
terraform init
terraform apply
```

### 4. ECR

```bash
cd ../03-ecr-repositories
terraform init
terraform apply
```

---

## 🔧 Variables Clave

| Variable          | Descripción                       | Valor por Defecto           |
| :---------------- | :-------------------------------- | :-------------------------- |
| `public_key_path` | Ruta a tu clave pública local     | `~/.ssh/id_rsa.pub`         |
| `domain_name`     | Dominio para el certificado       | `agevega.com`               |
| `bucket_name`     | Nombre único del bucket de assets | `agevegacom-assets-private` |
| `repo_name`       | Nombre del repositorio ECR        | `agevega-app`               |

---

## ⚡ Optimización y Costes

- **ECR Lifecycle**: Política de retención que mantiene solo las últimas 10 imágenes, evitando costes de almacenamiento innecesarios por builds antiguos.
- **Cero Tráfico S3 público**: Al usar OAC, el bucket no expone datos a internet, evitando ataques de listado y tráfico no deseado.
