# 02-bastion-EC2

Este módulo despliega un **Bastion Host** (EC2) altamente seguro para permitir el acceso administrativo a las redes privadas.  
Para facilitar la gestión y evitar dependencias circulares, el despliegue se divide en dos submódulos secuenciales.

![Architecture Diagram](../../diagrams/02-bastion-EC2.png)

---

## 🏛️ Arquitectura

El módulo se estructura en dos pasos lógicos:

1.  **`00-security`**: Prepara los componentes de identidad y red.

    - **Elastic IP (EIP):** IP estática reservada para el Bastion.
    - **Security Group:** Permite SSH (22) solo desde IPs confiables, y HTTP/HTTPS (80/443).
    - **Key Pair:** Sube tu clave pública SSH a AWS.

2.  **`01-instance`**: Despliega el cómputo.
    - **EC2 Instance:** `t3.micro` con Amazon Linux 2023.
    - **Ubicación:** Subred pública 1 (creada en `01-networking`).
    - **Asociación:** Vincula la EIP y el Security Group creados en el paso anterior.

---

## 🚀 Guía de Despliegue

Sigue este orden estricto para evitar errores de dependencias.

### Paso 1: Seguridad e Identidad (`00-security`)

Crea los grupos de seguridad, la clave SSH y reserva la IP elástica.

```bash
cd infra/terraform/02-bastion-EC2/00-security
terraform init
terraform apply
```

> **Nota:** Asegúrate de configurar correctamente `var.public_key_path` y `var.allowed_ssh_cidr_blocks` en tu `terraform.tfvars` o variables de entorno si difieren de los valores por defecto.

### Paso 2: Instancia (`01-instance`)

Lanza la instancia y le asigna los recursos de seguridad.

```bash
cd ../01-instance
terraform init
terraform apply
```

---

## 🗂️ Prerrequisitos

Este módulo depende del estado remoto de los módulos anteriores:

1.  **`00-setup`**: Backend S3/DynamoDB configurado.
2.  **`01-networking`**: VPC y subredes desplegadas.

---

## 🔧 Variables Importantes

### `00-security`

| Variable                  | Descripción                            | Valor por defecto                        |
| :------------------------ | :------------------------------------- | :--------------------------------------- |
| `public_key_path`         | Ruta local a tu clave pública (`.pub`) | `~/.ssh/id_rsa.pub`                      |
| `allowed_ssh_cidr_blocks` | Lista de CIDRs permitidos para SSH     | `["0.0.0.0/0"]` (Recomendado restringir) |

### `01-instance`

| Variable        | Descripción           | Valor por defecto |
| :-------------- | :-------------------- | :---------------- |
| `instance_type` | Tipo de instancia EC2 | `t3.micro`        |
| `environment`   | Etiqueta de entorno   | `lab`             |

---

## 📤 Outputs

- **Public IP:** La dirección IP fija del Bastion para conectarte.
- **Key Name:** El nombre de la clave SSH registrada en AWS.

```bash
# Ejemplo de conexión
ssh -i ~/.ssh/id_rsa ec2-user@<BASTION_PUBLIC_IP>
```
