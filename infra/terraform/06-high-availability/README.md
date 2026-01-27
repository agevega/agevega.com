# 06-ha-autoscaling

Este módulo despliega el entorno de **Producción en Alta Disponibilidad (HA)**. Utiliza instancias EC2 Spot orquestadas por un Auto Scaling Group (ASG), servidas a través de un Application Load Balancer (ALB) y protegidas por CloudFront y WAF.

**Características Principales:**

- **Alta Disponibilidad**: ASG distribuido en 3 zonas de disponibilidad.
- **Eficiencia de Costes**: Uso de instancias Spot (`t4g.nano`).
- **Seguridad Robusta**:
  - **WAF Global**: Protege la distribución de CloudFront (Región `us-east-1`).
  - **ALB Privado**: El ALB solo acepta tráfico desde CloudFront (Managed Prefix List).
  - **IMDSv2**: Enforce de tokens de sesión para metadatos de instancias (prevención SSRF).
  - **EC2 Aislado**: Las instancias solo aceptan tráfico HTTP del ALB y SSH del Bastion.
- **Activos Compartidos**: Integra el bucket de S3 del Módulo 05 para servir assets estáticos (`/assets/*`).

---

## 🏛️ Arquitectura Modular

El módulo se divide en 4 componentes secuenciales:

1.  **`00-security`**:
    - **Security Groups**: Reglas estrictas. El ALB rechaza tráfico directo de internet, solo permite CloudFront.
    - **IAM**: Roles para EC2 (SSM, ECR).
2.  **`01-compute`**:
    - **ALB**: Balanceador de carga interno a la VPC (accesible por CloudFront).
    - **ASG & Launch Template**: Gestión del ciclo de vida de las instancias. Fuerza IMDSv2.
3.  **`02-waf`** (Global - `us-east-1`):
    - **Web ACL**: Firewall de aplicación web desplegado en `us-east-1` para proteger CloudFront.
4.  **`03-cloudfront`**:
    - **Distribución**: Punto de entrada global.
    - **Orígenes**:
      - ALB (Default): Para la aplicación web.
      - S3 Assets (Módulo 05): Para ficheros estáticos (`/assets/*`) vía OAC.
    - **Caching**: TTL de 1 hora (3600s) para optimizar rendimiento.

---

## 🚀 Guía de Despliegue Secuencial

Sigue este orden estricto debido a las dependencias de estado (`terraform_remote_state`):

### 1. Seguridad (`00-security`)

```bash
cd infra/terraform/06-ha-autoscaling/00-security
terraform init
terraform apply
```

### 2. Cómputo (`01-compute`)

```bash
cd ../01-compute
terraform init
terraform apply
```

### 3. WAF (`02-waf`)

**Importante**: Este recurso debe desplegarse en `us-east-1` (configurado automáticamente en `provider.tf`).

```bash
cd ../02-waf
terraform init
terraform apply
```

### 4. CloudFront (`03-cloudfront`)

Este paso integrará el ALB, el WAF y el bucket de S3 del Módulo 05.

```bash
cd ../03-cloudfront
terraform init
terraform apply
```

---

## 🔒 Detalles de Seguridad

### Protección del ALB

Para evitar que los atacantes se salten el WAF accediendo directamente al ALB, hemos implementado una restricción basada en **Prefix List**.

- **Regla**: Ingress Port 80.
- **Origen**: `com.amazonaws.global.cloudfront.origin-facing`.
- **Efecto**: El ALB descarta cualquier paquete que no provenga de la red de CloudFront.

### Protección de Instancias (IMDSv2)

Para mitigar riesgos de SSRF, las instancias requieren **IMDSv2**:

- `http_tokens = "required"`
- `http_put_response_hop_limit = 1`

---

## 🛑 Gestión del WAF

Para destruir o desvincular el WAF sin errores:

1.  **Desvincular en CloudFront**:
    ```bash
    cd infra/terraform/06-ha-autoscaling/03-cloudfront
    terraform apply -var="enable_waf=false"
    ```
2.  **Destruir WAF**:
    ```bash
    cd ../02-waf
    terraform destroy
    ```
