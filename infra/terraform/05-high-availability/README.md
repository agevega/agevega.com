# 🚀 05-high-availability

Este módulo despliega el entorno de **Producción**, diseñado para máxima disponibilidad, resiliencia y escalabilidad utilizando instancias Spot.

---

## 🏛️ Arquitectura

- **Spot Fleet**: Cluster de instancias `t4g.nano` gestionadas por un ASG en 3 zonas de disponibilidad, logrando hasta un 90% de descuento en cómputo.
- **Load Balancing**: ALB interno que distribuye tráfico y realiza health checks.
- **Frontal Seguro**: El tráfico entra exclusivamente por CloudFront ya que el ALB solo acepta peticiones de este.
- **Seguridad**:
  - **IMDSv2**: Forzado en todas las instancias para mitigar SSRF.
  - **Prefix List**: El ALB solo acepta tráfico desde CloudFront.
  - **WAF (Opcional)**: Protección contra ataques web comunes (habilitado por defecto).

---

## 📂 Componentes (Submódulos)

### 1. [00-security](./00-security)

- **Función**: Firewalls y Seguridad de Red.
- **Recursos**: Security Groups (ALB e Instancias), Prefix Lists de CloudFront.

### 2. [01-ec2-autoscaling](./01-ec2-autoscaling)

- **Función**: Cómputo elástico.
- **Recursos**: Auto Scaling Group, Launch Template, Application Load Balancer.

### 3. [02-waf](./02-waf)

- **Función**: Protección Web.
- **Recursos**: Web ACL dedicada para producción en `us-east-1`.

### 4. [03-cloudfront](./03-cloudfront)

- **Función**: CDN Global.
- **Recursos**: Distribución con orígenes múltiples (S3 y ALB).

### 5. [04-dns-record](./04-dns-record)

- **Función**: Registro DNS Final.
- **Recursos**: Registro `A` (Alias) en Route53 (`agevega.com` y `www.agevega.com`) apuntando a CloudFront.

---

## 🚀 Guía de Despliegue

> El orden es **estricto** debido a las dependencias.

### 1. Seguridad

```bash
cd 00-security
terraform init
terraform apply
```

### 2. Computación (ASG + ALB)

```bash
cd 01-ec2-autoscaling
terraform init
terraform apply
```

### 3. WAF Production

```bash
cd 02-waf
terraform init
terraform apply
```

### 4. CloudFront Final

```bash
cd 03-cloudfront
terraform init
terraform apply
```

### 5. DNS Record

```bash
cd 04-dns-record
terraform init
terraform apply
```

---

## 🐞 Debug

Conectar a una instancia del ASG por SSH a través del Bastion Host:

```bash
ssh -i ~/.ssh/id_rsa -J ec2-user@$(aws ec2 describe-instances --filters "Name=tag:Name,Values=bastion-host" "Name=instance-state-name,Values=running" --query "Reservations[*].Instances[*].[PublicDnsName]" --output text --profile=terraform) ec2-user@<IP_PRIVADA_DESTINO>
```

---

## 🔧 Variables Clave

| Submódulo | Variable           | Descripción                     | Valor por Defecto |
| :-------- | :----------------- | :------------------------------ | :---------------- |
| `01`      | `desired_capacity` | Número objetivo de instancias   | `2`               |
| `01`      | `min_size`         | Mínimo de instancias en ASG     | `1`               |
| `01`      | `max_size`         | Máximo de instancias (escalado) | `3`               |
| `01`      | `instance_type`    | Familia de instancias           | `t4g.nano`        |
| `03`      | `enable_waf`       | Activa asociación de Web ACL    | `true`            |
| `04`      | `domain_name`      | Dominio raíz                    | `agevega.com`     |

---

## ⚡ Optimización y Costes

- **Spot Instances**: Uso de instancias Spot (`t4g.nano`) logrando hasta un ~70-90% de ahorro frente a On-Demand. El ASG maneja las interrupciones automáticamente.
- **Prefix List Security**: El ALB solo es accesible desde CloudFront, eliminando la necesidad de un WAF regional exclusivo para el ALB.
- **WAF Opcional**: Aunque recomendado para producción, el diseño permite desactivarlo para optimizar costes en escenarios de bajo riesgo o tráfico.
