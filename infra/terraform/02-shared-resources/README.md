# 📦 02-shared-resources

Este módulo centraliza recursos compartidos que son prerequisitos para otros módulos o que tienen un ciclo de vida global independiente.  
Estos componentes son consumidos tanto por el entorno de desarrollo (Bastion) como por el de producción (HA).

---

## 🏛️ Arquitectura

- **Gestión de Identidad (SSH)**: Clave pública centralizada para acceso EC2.
- **Contenido Estático**: Buckets S3 privados accesibles solo vía OAC (CloudFront).
- **Contenedores**: Repositorios ECR con políticas de ciclo de vida automáticas.
- **Certificados TLS (Regional)**: ACM certificate en `eu-south-2` para el ALB de producción.

_(Nota: La gestión de Certificados y Dominios se ha movido al módulo dedicado `99-domain`)_.

_(Nota: El certificado que usan las distribuciones CloudFront vive en `99-domain/01-acm-certificate` en `us-east-1` — es un recurso distinto. Este módulo gestiona exclusivamente el certificado regional del ALB)_.

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

### 4. [03-acm-certificates](./03-acm-certificates)

- **Función**: Certificado TLS regional para el ALB de producción (`eu-south-2`).
- **Recursos**: ACM Certificate con validación DNS automática (Route53). SANs: `agevega.com`, `*.agevega.com`, `*.academy.agevega.com`.
- **Consumidores**: `05-high-availability/01-ec2-autoscaling` (listener HTTPS del ALB).
- **Lifecycle**: `create_before_destroy = true` — al cambiar SANs, el cert nuevo se emite antes de destruir el antiguo. Requiere apply en 3 fases si el ALB listener apunta al cert viejo (ver nota más abajo).

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

### 4. ACM Certificate (03-acm-certificates)

```bash
cd ../03-acm-certificates
terraform init
terraform apply
```

> [!WARNING]
> **Al modificar SANs** (ej. añadir un nuevo subdominio nested), el apply requiere 3 fases:
> 1. `03-acm-certificates apply` — emite cert nuevo; la destrucción del antiguo falla porque el ALB listener aún lo referencia (`ResourceInUseException`). Es esperado.
> 2. `05-high-availability/01-ec2-autoscaling apply` — el ALB listener adopta el nuevo cert ARN (leído del remote state).
> 3. `03-acm-certificates apply` (de nuevo) — ahora el cert antiguo ya no está en uso y se destruye limpiamente.

---

## 🔧 Variables Clave

| Submódulo | Variable                  | Descripción                        | Valor por Defecto           |
| :-------- | :------------------------ | :--------------------------------- | :-------------------------- |
| `00`      | `public_key_path`         | Ruta a tu clave pública local      | `~/.ssh/id_rsa.pub`         |
| `01`      | `repository_name_landing` | Nombre del ECR landing             | `agevegacom-landing`        |
| `01`      | `repository_name_academy` | Nombre del ECR academy             | `agevegacom-academy`        |
| `02`      | `assets_bucket_name`      | Nombre único del bucket de assets  | `agevegacom-assets-private` |

---

## ⚡ Optimización y Costes

- **ECR Lifecycle**: Política de retención (Keep Last 10) para evitar costes de almacenamiento innecesarios por builds antiguos.
- **Cero Tráfico S3 público**: Al usar OAC, el bucket no expone datos a internet, evitando ataques de listado y tráfico no deseado.
