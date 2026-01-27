# 04-bastion-host

Este módulo despliega el punto de entrada administrativo y público de la infraestructura. Combina el Bastion Host (para acceso SSH seguro) y la distribución CloudFront principal (para entrega de contenido estático y enrutamiento).

## 📂 Submódulos

### 1. [00-security](./00-security)

- **Descripción**: Security Group para el Bastion Host.
- **Reglas**: Permite SSH (22) desde IPs autorizadas y tráfico HTTP desde CloudFront (para el paso a través si fuera necesario).

### 2. [01-eip](./01-eip)

- **Descripción**: Elastic IP fija para el Bastion Host. Facilita la configuración de DNS y reglas de firewall en cliente.

### 3. [02-ec2-instance](./02-ec2-instance)

- **Descripción**: Instancia EC2 (`t4g.nano` ARM64) que actúa como Bastion Host.
- **OS**: Amazon Linux 2023.

### 4. [03-waf](./03-waf)

- **Descripción**: Web Application Firewall (WAF) asociado a CloudFront.
- **Reglas**: AWS Managed Rules (Common Rule Set) para protección básica contra exploits comunes.

### 5. [04-cloudfront](./04-cloudfront)

- **Descripción**: Distribución global de contenido.
- **Orígenes**:
  - **S3 Assets** (via `02-shared-resources`): Para contenido estático `/assets/*`.
  - **Bastion Host** (via HTTP Proxy): Origen por defecto (aunque su uso principal es túnel SSH, la arquitectura permite servir HTTP simple si se requiere).
- **Seguridad**: Solo acepta HTTPS (redirección automática), TLS 1.2+, y está protegido por WAF.

## 🚀 Guía de Despliegue

Orden estricto debido a dependencias internas:

```bash
# 1. Grupo de Seguridad
cd 00-security
terraform init
terraform apply

# 2. Elastic IP
cd ../01-eip
terraform init
terraform apply

# 3. WAF (Debe existir antes de CloudFront)
cd ../03-waf
terraform init
terraform apply

# 4. Instancia Bastion (Depende de Security y EIP)
cd ../02-ec2-instance
terraform init
terraform apply

# 5. CloudFront (Depende de WAF, EIP y recursos compartidos)
cd ../04-cloudfront
terraform init
terraform apply
```
