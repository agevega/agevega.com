# 02-shared-resources

Este módulo centraliza servicios y recursos compartidos que son prerequisitos para otros módulos o que tienen un ciclo de vida global independiente.

## 📂 Submódulos

### 1. [00-ssh-keys](./00-ssh-keys)

- **Descripción**: Gestiona la clave pública SSH (`bastion-key`) utilizada por las instancias EC2 (Bastion, ASG) para permitir el acceso administrativo.

### 2. [01-acm-certificates](./01-acm-certificates)

- **Descripción**: Emite y valida certificados SSL/TLS en `us-east-1` (N. Virginia) para su uso en CloudFront.
- **Nota**: CloudFront requiere que los certificados estén en esta región específica.

### 3. [02-s3-buckets](./02-s3-buckets)

- **Descripción**: Buckets S3 privados para almacenamiento de activos estáticos (ej: CV, documentos) servidos vía CloudFront.
- **Acceso**: Restringido exclusivamente a CloudFront mediante OAC (Origin Access Control).

### 4. [03-ecr-repositories](./03-ecr-repositories)

- **Descripción**: Registro de contenedores Docker (ECR) para las imágenes de aplicación.
- **Features**: Escaneo de vulnerabilidades en push y políticas de ciclo de vida (retención de últimas 10 imágenes).

## 🚀 Guía de Despliegue

Debido a la independencia de estos recursos, el orden dentro del módulo no es estricto, pero se recomienda seguir la numeración:

```bash
# 1. SSH Keys
cd 00-ssh-keys
terraform init
terraform apply

# 2. Certificados (Tarda unos minutos en validar DNS)
cd ../01-acm-certificates
terraform init
terraform apply

# 3. S3 Assets
cd ../02-s3-buckets
terraform init
terraform apply

# 4. ECR
cd ../03-ecr-repositories
terraform init
terraform apply
```
