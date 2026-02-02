# 📦 02-shared-resources

Este módulo centraliza recursos compartidos que son prerequisitos para otros módulos o que tienen un ciclo de vida global independiente.  
Estos componentes son consumidos tanto por el entorno de desarrollo (Bastion) como por el de producción (HA).

---

## 🏛️ Arquitectura

- **Gestión de Identidad (SSH)**: Clave pública centralizada para acceso EC2.
- **Contenido Estático**: Buckets S3 privados accesibles solo vía OAC (CloudFront).
- **Contenedores**: Repositorios ECR con políticas de ciclo de vida automáticas.

_(Nota: La gestión de Certificados y Dominios se ha movido al módulo dedicado `99-domain`)_.

---

## 📂 Componentes (Submódulos)

### 1. [00-ssh-keys](./00-ssh-keys)

- **Función**: Acceso e identidad.
- **Recursos**: Key Pair. Sube tu clave pública SSH a AWS para permitir el acceso a las instancias.

### 2. [01-ecr-repositories](./01-ecr-repositories)

- **Función**: Registro de imágenes Docker.
- **Recursos**: ECR Repository con escaneo de vulnerabilidades. Política de ciclo de vida para retener solo las últimas 10 imágenes.

### 3. [02-s3-buckets](./02-s3-buckets)

- **Función**: Almacenamiento de assets (CV, imágenes).
- **Recursos**: Bucket S3 privado con encriptación AES256.

---

## 🚀 Guía de Despliegue

Seguir la secuencia numérica para mantener el orden lógico.

### 1. SSH Keys (00-ssh-keys)

```bash
cd 00-ssh-keys
terraform init
terraform apply -var="public_key_path=~/.ssh/id_rsa.pub"
```

### 2. ECR (01-ecr-repositories)

```bash
cd ../01-ecr-repositories
terraform init
terraform apply
```

### 3. S3 Assets (02-s3-buckets)

```bash
cd ../02-s3-buckets
terraform init
terraform apply
```

---

## 🔧 Variables Clave

| Submódulo | Variable             | Descripción                       | Valor por Defecto           |
| :-------- | :------------------- | :-------------------------------- | :-------------------------- |
| `00`      | `public_key_path`    | Ruta a tu clave pública local     | `~/.ssh/id_rsa.pub`         |
| `01`      | `repository_name`    | Nombre del repositorio ECR        | `agevegacom-frontend`       |
| `02`      | `assets_bucket_name` | Nombre único del bucket de assets | `agevegacom-assets-private` |

---

## ⚡ Optimización y Costes

- **ECR Lifecycle**: Política de retención (Keep Last 10) para evitar costes de almacenamiento innecesarios por builds antiguos.
- **Cero Tráfico S3 público**: Al usar OAC, el bucket no expone datos a internet, evitando ataques de listado y tráfico no deseado.
