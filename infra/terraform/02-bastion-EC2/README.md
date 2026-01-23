# 02-bastion-EC2

Este módulo despliega un **Bastion Host** (EC2) para permitir el acceso administrativo a las redes privadas.  
Para facilitar la gestión y evitar dependencias circulares, el despliegue se divide en dos submódulos.

![Architecture Diagram](../../diagrams/02-bastion-EC2.png)

---

## 🏛️ Arquitectura

1.  **`00-security`**: Define los Security Groups.
    - **Security Group:** Permite SSH (22) y crea las reglas de tráfico.

2.  **`01-ssh-key`**: Gestión de identidad.
    - **Key Pair:** Sube tu clave pública SSH a AWS.

3.  **`02-eip`**: Networking estático.
    - **Elastic IP (EIP):** IP estática reservada para el Bastion.

4.  **`03-instance`**: Cómputo.
    - **EC2 Instance:** `t4g.nano` (ARM64) y asociación de recursos.

---

## 🚀 Guía de Despliegue

Sigue este orden para evitar errores de dependencias.

### Paso 1: Seguridad (`00-security`)

Define los grupos de seguridad (Security Groups).

```bash
cd infra/terraform/02-bastion-EC2/00-security
terraform init
terraform apply
```

### Paso 2: Llave SSH (`01-ssh-key`)

Registra tu clave pública en AWS.

```bash
cd ../01-ssh-key
terraform init
terraform apply -var="public_key_path=~/.ssh/id_rsa.pub"
```

### Paso 3: Elastic IP (`02-eip`)

Reserva una IP elástica estática.

```bash
cd ../02-eip
terraform init
terraform apply
```

### Paso 4: Instancia (`03-instance`)

Lanza la instancia y asocia los recursos.

```bash
cd ../03-instance
terraform init
terraform apply
```

---

## 🗂️ Prerrequisitos

Este módulo depende del estado remoto de los módulos anteriores:

1.  **`00-setup/00-backend-S3`**: Backend S3/DynamoDB configurado.
2.  **`01-networking/00-vpc-core`**: VPC y subredes desplegadas.

---

## 🔧 Variables Importantes

### `00-security`

| Variable                  | Descripción                        | Valor por defecto                        |
| :------------------------ | :--------------------------------- | :--------------------------------------- |
| `allowed_ssh_cidr_blocks` | Lista de CIDRs permitidos para SSH | `["0.0.0.0/0"]` (Recomendado restringir) |

### `01-ssh-key`

| Variable          | Descripción                            | Valor por defecto   |
| :---------------- | :------------------------------------- | :------------------ |
| `public_key_path` | Ruta local a tu clave pública (`.pub`) | `~/.ssh/id_rsa.pub` |

### `03-instance`

| Variable        | Descripción           | Valor por defecto |
| :-------------- | :-------------------- | :---------------- |
| `instance_type` | Tipo de instancia EC2 | `t4g.nano`        |
| `environment`   | Etiqueta de entorno   | `lab`             |

---

## 📤 Outputs

- **Public IP:** La dirección IP fija del Bastion para conectarte.
- **Key Name:** El nombre de la clave SSH registrada en AWS.

```bash
# Ejemplo de conexión
ssh -i ~/.ssh/id_rsa ec2-user@<BASTION_PUBLIC_IP>
```
