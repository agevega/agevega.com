# 🛡️ 04-bastion-host

Este módulo despliega el punto de entrada administrativo y la distribución de contenido de la infraestructura de desarrollo (dev). Combina seguridad perimetral y acceso remoto seguro.

![Architecture Diagram](../../diagrams/02-bastion-EC2.png)

---

## 🏛️ Arquitectura

- **Bastion Host**: Instancia EC2 mínima (`t4g.nano`) en subred pública para tunelización SSH.
- **CDN Global**: CloudFront actúa como frontal para el contenido estático, sirviendo como entorno de desarrollo.
- **Seguridad**:
  - **Security Groups**: Whitelist para acceso SSH.
  - **WAF (Opcional)**: Protección contra ataques web comunes (deshabilitado por defecto).
  - **EIP (Opcional)**: IP estática para persistencia DNS (deshabilitado por defecto).

---

## 📂 Componentes (Submódulos)

### 1. [00-security](./00-security)

- **Función**: Firewall de red.
- **Recursos**: Security Groups para Bastion (SSH 22, HTTP 80, HTTPS 443).

### 2. [01-eip](./01-eip) (Opcional)

- **Función**: IP Estática.
- **Recursos**: Elastic IP para asegurar persistencia de DNS en el Bastion.

### 3. [02-ec2-instance](./02-ec2-instance)

- **Función**: Cómputo.
- **Recursos**: Instancia EC2 Amazon Linux 2023.

### 4. [03-waf](./03-waf) (Opcional)

- **Función**: Protección Web.
- **Recursos**: Web ACL (AWS Managed Rules) en `us-east-1`.

### 5. [04-cloudfront](./04-cloudfront)

- **Función**: CDN Global.
- **Recursos**: Distribución con orígenes múltiples (S3 y EC2).

### 6. [05-dns-record](./05-dns-record)

- **Función**: Registro DNS Final.
- **Recursos**: Registro `A` (Alias) en Route53 (`dev.agevega.com`) apuntando a CloudFront.

---

## 🚀 Guía de Despliegue

> El orden es **estricto** debido a las dependencias. Por defecto, **NO** se despliegan ni EIP ni WAF para optimizar costes.

### 1. Grupos de Seguridad

```bash
cd 00-security
terraform init
terraform apply
```

### 2. Instancia Bastion (con/sin EIP)

**Opción A: Sin IP Elástica (Recomendado/Default)**
Usa Public DNS dinámico. Más barato aunque el DNS cambia si reinicias la instancia.

```bash
cd 02-ec2-instance
terraform init
terraform apply
# Variable enable_eip es false por defecto
```

**Opción B: Con IP Elástica**
IP fija y persistente. Coste adicional.

```bash
# 1. Crear EIP
cd 01-eip
terraform init
terraform apply

# 2. Asociar a Instancia
cd 02-ec2-instance
terraform init
terraform apply -var="enable_eip=true"
```

### 3. CloudFront (con/sin WAF)

**Opción A: Sin WAF (Recomendado/Default)**
Despliegue rápido y económico.

```bash
cd 04-cloudfront
terraform init
terraform apply
# Variable enable_waf es false por defecto
```

**Opción B: Con WAF**
Protección extra. Coste adicional (~$5/mes + tráfico).

```bash
# 1. Crear WAF
cd 03-waf
terraform init
terraform apply

# 2. Asociar a CloudFront
cd 04-cloudfront
terraform init
terraform apply -var="enable_waf=true"
```

### 4. DNS Record

```bash
cd 05-dns-record
terraform init
terraform apply
```

## 🛑 Gestión de EIP

Para desactivar y borrar la EIP:

1.  **Desactivar en Instancia**:
    ```bash
    cd 02-ec2-instance
    terraform apply -var="enable_eip=false"
    ```
2.  **Destruir EIP**:
    ```bash
    cd ../01-eip
    terraform destroy
    ```

## 🛑 Gestión del WAF

Para desvincular y destruir el WAF sin errores:

1. **Desvincular en CloudFront**:
   ```bash
   cd 04-cloudfront
   terraform apply -var="enable_waf=false"
   ```
2. **Destruir WAF**:
   ```bash
   cd ../03-waf
   terraform destroy
   ```

---

## 🐞 Debug

Conectar al Bastion Host a través de SSH sin EIP asociada:

```bash
ssh -A -i ~/.ssh/id_rsa ec2-user@$(aws ec2 describe-instances --filters "Name=tag:Name,Values=bastion-host" "Name=instance-state-name,Values=running" --query "Reservations[*].Instances[*].[PublicDnsName]" --output text --profile=terraform)
```

Ver logs de inicialización de la instancia:

```bash
sudo tail -f /var/log/cloud-init-output.log
```

---

## 🔧 Variables Clave

| Submódulo | Variable                  | Descripción                     | Default            |
| :-------- | :------------------------ | :------------------------------ | :----------------- |
| `00`      | `allowed_ssh_cidr_blocks` | IPs permitidas para SSH         | `["0.0.0.0/0"]`    |
| `02`      | `instance_type`           | Tipo de instancia EC2           | `t4g.nano` (ARM64) |
| `02`      | `enable_eip`              | Activa asociación de Elastic IP | `false`            |
| `04`      | `enable_waf`              | Activa asociación de Web ACL    | `false`            |
| `05`      | `domain_name`             | Dominio raíz                    | `agevega.com`      |

---

## ⚡ Optimización y Costes

- **EIP y WAF opcionales**: Son los componentes mas costosos de este submódulo y no son estrictamente imprescindibles para su funcionamiento, al estar en un entorno de desarrollo se han deshabilitado por defecto por ahorro de costes.
- **Instancia Nano ARM**: Uso de `t4g.nano` que ofrece el coste más bajo posible para una instancia EC2 on-demand, suficiente para un bastion host.
- **Http Proxy**: CloudFront está configurado para cachear contenido estático de S3, reduciendo peticiones al origen y costes de transferencia de datos.
