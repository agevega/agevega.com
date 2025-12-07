# 06/12/2025 — Despliegue de Bastion EC2 (Módulo 02)

Se ha creado y desplegado el módulo `02-bastion-EC2` para la gestión segura de accesos mediante un Bastion Host. El diseño sigue una arquitectura modular separando recursos persistentes de los efímeros para optimización de costes.

## 🚀 Cambios realizados

### Arquitectura dividida (Split Architecture)

Se ha implementado una estructura de doble estado para permitir la destrucción de la instancia de cómputo sin perder la configuración de seguridad ni la IP pública.

1.  **00-security (Persistente)**:

    - **Elastic IP (EIP)**: Dirección IP estática reservada para el bastión.
    - **Security Group**: Configuración de reglas de firewall.
      - **SSH (22)**: Permitido desde IPs autorizadas (`allowed_ssh_cidr_blocks`).
      - **HTTP (80) & HTTPS (443)**: Abierto a todo el mundo (`0.0.0.0/0`) para servir aplicaciones web.
    - **Key Pair**: Importación de clave pública SSH existente mediante ruta de archivo local.

2.  **01-instance (Efímero)**:
    - **EC2 Instance**: Instancia `t3.micro` con Amazon Linux 2023.
    - **User Data**: Script de arranque que instala y configura **Docker** automáticamente.
    - **Asociación EIP**: Vinculación automática de la IP elástica persistente a la nueva instancia al levantarse.

### Configuración y Estandarización

- Adopción de variables estándar `aws_region` y `aws_profile` para consistencia con el módulo `01-networking`.
- Uso de `terraform_remote_state` para recuperar dinámicamente VPC IDs y Subnet IDs del módulo de red.

## 📋 Instrucciones de uso

### Despliegue inicial (Seguridad)

```bash
cd infra/terraform/02-bastion-EC2/00-security
terraform init
terraform apply -var="public_key_path=~/.ssh/id_rsa.pub"
```

### Gestión del ciclo de vida (Instancia)

- **Iniciar servicio**: `cd 02-bastion-EC2/01-instance && terraform apply`
- **Detener servicio (Ahorro costes)**: `cd 02-bastion-EC2/01-instance && terraform destroy`

## ✅ Verificación

```bash
ssh -i /home/agevega/.ssh/ssh_key_agevega.pub ec2-user@51.49.170.108
docker info
```

---

### 💰 Coste estimado mensual

| Recurso           | Estimado mensual | Notas                                                                                    |
| :---------------- | :--------------- | :--------------------------------------------------------------------------------------- |
| **EC2 t3.micro**  | ~7.60 €          | Coste si está encendida 24/7 (eu-south-2).                                               |
| **Elastic IP**    | ~3.60 €          | **Gratis** si la instancia está corriendo. Se cobra si la instancia se destruye/detiene. |
| **EBS (8GB gp3)** | ~0.64 €          | Almacenamiento persistente del root volume.                                              |
| **Data Transfer** | Variable         | Coste por GB saliente a Internet.                                                        |

**Escenarios de coste:**

- **Activo 24/7**: ~8.24 €/mes (Instancia + EBS).
- **Inactivo (Destruido)**: ~4.24 €/mes (EIP retenida + EBS si no se borra snapshot, o solo EIP).

> [!NOTE]
> Al destruir la instancia (`terraform destroy` en `01-instance`), se deja de pagar por la computación (~0.0104 €/h) pero se empieza a pagar por la IP Elástica reservada no utilizada (~0.005 €/h). El ahorro real es de aprox. **0.005 €/hora** (~3.5 €/mes de ahorro máximo).
