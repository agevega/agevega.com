# 🛡️ 04-bastion-host

Este módulo despliega el punto de entrada de la red y las distribuciones de contenido de desarrollo (dev) para **landing** y **academy**. Combina seguridad perimetral, acceso remoto seguro y CDN global.

![Architecture Diagram](../../diagrams/02-bastion-EC2.png)

---

## 🏛️ Arquitectura

- **Bastion Host**: Instancia EC2 mínima (`t4g.nano`) en subred pública para tunelización SSH. Ejecuta **dos contenedores**: landing en host:443 y academy en host:8443.
- **CDN Global**: Dos distribuciones CloudFront (una por site) como frontal para el contenido de desarrollo. Cada distribución apunta al mismo bastion pero en puertos distintos.
- **Seguridad**:
  - **HTTPS-Only**: Tráfico cifrado End-to-End desde CloudFront hasta la aplicación, con certificado multi-SAN Let's Encrypt (DNS-01).
  - **Security Groups**: Whitelist para acceso SSH.
  - **EIP (Opcional)**: IP estática para el bastion (deshabilitado por defecto).
  - **WAF (Opcional)**: Protección contra ataques web (deshabilitado por defecto).

---

## 📂 Componentes (Submódulos)

### 1. [00-security](./00-security)

- **Función**: Firewall de red.
- **Recursos**: Security Groups (SSH 22, HTTPS 443, HTTPS 8443) y IAM Role para el Bastion.

### 2. [01-eip](./01-eip) (Opcional)

- **Función**: IP Estática.
- **Recursos**: Elastic IP para persistencia de DNS en el Bastion.

### 3. [02-ec2-instance](./02-ec2-instance)

- **Función**: Cómputo.
- **Recursos**: Instancia EC2 Amazon Linux 2023.

### 4. [03-waf](./03-waf) (Opcional)

- **Función**: Protección Web.
- **Recursos**: Web ACL (AWS Managed Rules) en `us-east-1`.

### 5. [04-cloudfront](./04-cloudfront)

- **Función**: CDN Global.
- **Recursos**: Dos distribuciones CloudFront con orígenes múltiples (EC2 Bastion + S3).
  - **Landing**: origin port 443 → `dev.agevega.com`
  - **Academy**: origin port 8443 → `dev.academy.agevega.com`

### 6. [05-dns-record](./05-dns-record)

- **Función**: Registros DNS de desarrollo.
- **Recursos**: Registros `A` (Alias) en Route53 apuntando a CloudFront:
  - `dev.agevega.com` → distribución landing
  - `dev.academy.agevega.com` → distribución academy

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

**Opción A: Sin IP Elástica (Default)**
Usa Public DNS dinámico.

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

**Opción C: Asumir tráfico de Producción**
Añade los aliases de producción a las distribuciones dev:
- Landing: `agevega.com`, `www.agevega.com`
- Academy: `academy.agevega.com`, `www.academy.agevega.com`

Requiere quitar previamente los aliases de las distribuciones de producción (módulo 05).

```bash
cd 04-cloudfront
terraform init
terraform apply -var="assume_prod=true"
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

Verificar contenedores en el bastion:

```bash
docker ps                          # Ambos contenedores: app (landing:443), academy (:8443)
curl -k https://localhost/         # Landing
curl -k https://localhost:8443/    # Academy
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
| `04`      | `assume_prod`             | Asume aliases de producción     | `false`            |
| `05`      | `domain_name`             | Dominio raíz                    | `agevega.com`      |

---

## ⚡ Optimización y Costes

- **EIP y WAF opcionales**: Son los componentes mas costosos de este submódulo y no son estrictamente imprescindibles para su funcionamiento, al estar en un entorno de desarrollo se han deshabilitado por defecto por ahorro de costes.
- **Instancia Nano ARM**: Uso de `t4g.nano` que ofrece el coste más bajo posible para una instancia EC2 on-demand, suficiente para un bastion host.
- **Single EC2, dual container**: Ambos sites comparten la misma instancia, eliminando el coste de una segunda EC2 para academy.
