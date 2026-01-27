# 05-high-availability

Este módulo despliega la infraestructura de producción principal, diseñada para **Alta Disponibilidad (HA)** y escalabilidad automática.

## 📂 Submódulos

### 1. [00-security](./00-security)

- **Descripción**: Grupos de seguridad para el balanceador (ALB) y las instancias de aplicación.
- **Flujo**:
  - **ALB SG**: Acepta tráfico HTTP (80) solo desde CloudFront (vía Prefix List).
  - **Instance SG**: Acepta tráfico HTTP (80) solo desde el ALB SG y SSH (22) solo desde el Bastion SG.

### 2. [01-ec2-autoscaling](./01-ec2-autoscaling)

- **Descripción**: El núcleo de computación.
- **Componentes**:
  - **Auto Scaling Group (ASG)**: Gestiona el ciclo de vida de las instancias. Mínimo 1, Máximo 3, Deseado 2.
  - **Application Load Balancer (ALB)**: Distribuye el tráfico entre las instancias del ASG. Interno=falso (público), pero protegido por SG.
  - **Launch Template**: Define la configuración de las instancias (AMI Amazon Linux 2023, Tipo instancia variable, User Data para arrancar Docker).
  - **Spot Instances**: Configurado para usar instancias Spot para optimización de costes.

### 3. [02-waf](./02-waf)

- **Descripción**: WAF dedicado para la distribución de CloudFront de producción.

### 4. [03-cloudfront](./03-cloudfront)

- **Descripción**: CDN global para la aplicación principal (`agevega.com` y `www.agevega.com`).
- **Orígenes**:
  - **S3 Assets**: Para `/assets/*`.
  - **ALB**: Para el resto del tráfico (aplicación dinámica/SSR).

## 🚀 Guía de Despliegue

El orden es crítico:

```bash
# 1. Seguridad
cd 00-security
terraform init
terraform apply

# 2. Computación (ASG + ALB)
cd ../01-ec2-autoscaling
terraform init
terraform apply

# 3. WAF
cd ../02-waf
terraform init
terraform apply

# 4. CloudFront Final
cd ../03-cloudfront
terraform init
terraform apply
```
