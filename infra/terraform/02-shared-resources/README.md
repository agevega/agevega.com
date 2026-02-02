# 📦 02-shared-resources

Este módulo centraliza recursos compartidos que son prerequisitos para otros módulos o que tienen un ciclo de vida global independiente.

---

## 🏛️ Arquitectura

Los recursos aquí definidos son consumidos tanto por el entorno de desarrollo (Bastion) como por el de producción (HA).

- **Gestión de Identidad (SSH)**: Clave pública centralizada para acceso EC2.
- **Contenido Estático**: Buckets S3 privados accesibles solo vía OAC (CloudFront).
- **Contenedores**: Repositorios ECR con políticas de ciclo de vida automáticas.

---

## 📂 Componentes (Submódulos)

### 1. [00-ssh-keys](./00-ssh-keys)

- **Función**: Acceso e identidad.
- **Recursos**: Key Pair. Sube tu clave pública SSH a AWS para permitir el acceso a las instancias.

### 2. [01-ecr-repositories](./01-ecr-repositories)

- **Función**: Registro de imágenes Docker.
- **Recursos**: ECR Repository con escaneo de vulnerabilidades. Retención de últimas 10 imágenes.

### 3. [02-s3-buckets](./02-s3-buckets)

- **Función**: Almacenamiento de assets (CV, imágenes).
- **Recursos**: Bucket S3 privado con encriptación AES256.

---

## 🚀 Guía de Despliegue

Debido a la independencia de estos recursos, el orden dentro del módulo no es estricto, pero se recomienda seguir la numeración:

### 1. SSH Keys

```bash
cd 00-ssh-keys
terraform init
terraform apply -var="public_key_path=~/.ssh/id_rsa.pub"
```

### 2. ECR

```bash
cd ../01-ecr-repositories
terraform init
terraform apply
```

### 3. S3 Assets

```bash
cd ../02-s3-buckets
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
