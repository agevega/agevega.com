# 🚀 05-high-availability

Este módulo despliega el entorno de **Producción**, diseñado para máxima disponibilidad y escalabilidad automática utilizando instancias Spot.

---

## 🏛️ Arquitectura

Arquitectura tolerante a fallos distribuida en 3 zonas de disponibilidad.

- **Spot Fleet**: Cluster de instancias `t4g.nano` gestionadas por ASG, logrando hasta un 90% de descuento en cómputo.
- **Load Balancing**: ALB interno que distribuye tráfico y realiza health checks.
- **Frontal Seguro**: El tráfico entra exclusivamente por CloudFront + WAF. El ALB solo acepta peticiones de CloudFront (verificado por Prefix List).
- **Seguridad Instancias**: IMDSv2 forzado para mitigación de SSRF.

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

### 1. Seguridad

```bash
cd 00-security
terraform init
terraform apply
```

### 2. Computación (ASG + ALB)

```bash
cd ../01-ec2-autoscaling
terraform init
terraform apply
```

### 3. WAF Production

```bash
cd ../02-waf
terraform init
terraform apply
```

### 4. CloudFront Final

```bash
cd ../03-cloudfront
terraform init
terraform apply
```

### 5. DNS Record

```bash
cd ../04-dns-record
terraform init
terraform apply
```

## 🛑 Gestión del WAF

Para destruir o desvincular el WAF sin errores:

1. **Desvincular en CloudFront**:
   ```bash
   cd 03-cloudfront
   terraform apply -var="enable_waf=false"
   ```
2. **Destruir WAF**:
   ```bash
   cd ../02-waf
   terraform destroy
   ```

---

## 🔧 Variables Clave

| Submódulo | Variable           | Descripción                     | Valor por Defecto |
| :-------- | :----------------- | :------------------------------ | :---------------- |
| `01`      | `desired_capacity` | Número objetivo de instancias   | `2`               |
| `01`      | `min_size`         | Mínimo de instancias en ASG     | `1`               |
| `01`      | `max_size`         | Máximo de instancias (escalado) | `3`               |
| `01`      | `instance_type`    | Familia de instancias           | `t4g.nano`        |
| `04`      | `domain_name`      | Dominio raíz                    | `agevega.com`     |

---

## ⚡ Optimización y Costes

- **Spot Instances**: El uso de instancias Spot para el entorno de producción reduce drásticamente los costes. Al estar detrás de un ASG y ALB, la posible interrupción de una instancia es manejada automáticamente reemplazándola por otra.
- **Prefix List Security**: Implementación de Security Groups basados en Prefix Lists de CloudFront para restringir el acceso al ALB. Esto permite prescindir de un WAF regional, optimizando costes y delegando la seguridad de capa 7 íntegramente a CloudFront WAF.
