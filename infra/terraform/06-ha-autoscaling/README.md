# 06-ha-autoscaling

Este módulo despliega un entorno de **Producción en Alta Disponibilidad (HA)** totalmente independiente del entorno de desarrollo. Utiliza instancias EC2 Spot orquestadas por un Auto Scaling Group (ASG) y servidas a través de un Application Load Balancer (ALB) y CloudFront.

**Características Principales:**

- **Alta Disponibilidad**: ASG distribuido en 3 zonas de disponibilidad.
- **Eficiencia de Costes**: Uso de instancias Spot.
- **Seguridad**: Seguridad perimetral con WAF, CloudFront y Security Groups estrictos (EC2 solo acepta tráfico del ALB).
- **Inmutabilidad**: Despliegues basados en "Instance Refresh" (nuevas instancias para cada cambio).
- **WAF Opcional**: Lógica idéntica al Módulo 05 para vincular/desvincular el WAF sin fricción.

---

## 🏛️ Arquitectura Granular

El módulo se divide en 4 componentes secuenciales para aislar responsabilidades:

1.  **`00-security`**:
    - **IAM Role**: Permisos para que las instancias descarguen imágenes de ECR.
    - **Security Groups**: Definición de reglas de firewall (ALB público, EC2 privado).
2.  **`01-compute`**:
    - **ALB**: Balanceador de carga público.
    - **Launch Template**: Plantilla de arranque con Docker y User Data.
    - **ASG**: Grupo de autoescalado que gestiona el ciclo de vida de las instancias.
    - _Dependencia_: Necesita los Security Groups y Perfiles IAM de `00-security`.
3.  **`02-waf`**:
    - **Web ACL**: Firewall de aplicación web dedicado para Producción.
4.  **`03-cloudfront`**:
    - **Distribución**: Punto de entrada global (CDN).
    - _Dependencia_: Apunta al ALB (`01-compute`) y se protege con el WAF (`02-waf`).

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

- **Verificación**: Comprueba en la consola EC2 que las instancias se están lanzando.

### 3. WAF (`02-waf`)

Este paso es **opcional** si deseas desactivar el WAF temporalmente (ver abajo), pero recomendado para producción.

```bash
cd ../02-waf
terraform init
terraform apply
```

### 4. CloudFront (`03-cloudfront`)

La distribución detectará automáticamente la configuración del WAF.

```bash
cd ../03-cloudfront
terraform init
terraform apply
```

**Comportamiento Automático del WAF:**

- **Variable `enable_waf = true`** (defecto) + **Estado remoto existe**: Se asocia el WAF.
- **Variable `enable_waf = false`** O **Estado remoto no existe**: Se ignora el WAF.

---

## 🛑 Gestión del WAF (Desvinculación y Destrucción)

Para destruir el WAF sin errores de dependencia (`WAFAssociatedItemException`):

1.  **Desvincular WAF**: Actualiza CloudFront ignorando el WAF.
    ```bash
    cd infra/terraform/06-ha-autoscaling/03-cloudfront
    terraform apply -var="enable_waf=false"
    ```
2.  **Destruir WAF**:
    ```bash
    cd ../02-waf
    terraform destroy
    ```
3.  **Restaurar (Opcional)**: Deja la variable en `true` para el futuro.
    ```bash
    cd ../03-cloudfront
    terraform apply
    ```

---

## 🔧 Variables Importantes

### `03-cloudfront`

| Variable     | Descripción                                             | Valor por defecto |
| :----------- | :------------------------------------------------------ | :---------------- |
| `enable_waf` | Activa la asociación del WAF. `false` para desvincular. | `true`            |
