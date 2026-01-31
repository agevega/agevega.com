# 🌐 01-networking

Este módulo despliega la **Infraestructura de Red (VPC)** base. Diseñada en 3 capas para máxima seguridad y segmentación.

---

## 🏛️ Arquitectura

La red se estructura en una VPC con direccionamiento `10.0.0.0/16` dividida en subredes por función.

- **VPC Tiering**:
  - **Public**: Para recursos con acceso directo a Internet.
  - **Private**: Para cargas de trabajo en alta disponibilidad. Salida a Internet a través del NAT Gateway.
  - **Data/Secure**: Para datos y persistencia (RDS, DynamoDB). Aislada de internet.
- **Conectividad**: El NAT Gateway está desacoplado para permitir su apagado y reducir costes.

---

## 📂 Componentes (Submódulos)

### 1. [00-vpc-core](./00-vpc-core)

- **Función**: Red troncal.
- **Recursos**: VPC, Subnets (Public/Private), Internet Gateway, Route Tables.

### 2. [01-nat-gateway](./01-nat-gateway)

- **Función**: Salida a Internet para redes privadas.
- **Recursos**: NAT Gateway, Elastic IP, Rutas `0.0.0.0/0` en tablas privadas.
- **Nota**: **Opcional**. Desplegar únicamente si se requiere conectividad de salida a Internet para los recursos en subredes privadas.

### 3. [02-vpc-endpoints](./02-vpc-endpoints)

- **Función**: Acceso privado a servicios AWS.
- **Recursos**: Gateway Endpoint para S3.
- **Beneficio**: Permite acceder a S3 desde la red privada sin usar el NAT Gateway (ahorro de costes y tráfico).

---

## 🚀 Guía de Despliegue

### 1. Core (Obligatorio)

```bash
cd 00-vpc-core
terraform init
terraform apply
```

### 2. Endpoints (Recomendado)

```bash
cd ../02-vpc-endpoints
terraform init
terraform apply
```

### 3. NAT Gateway (Bajo Demanda)

```bash
cd ../01-nat-gateway
terraform init
terraform apply
# Destruir cuando no se use para ahorrar ~33€/mes
# terraform destroy
```

---

## 🔧 Variables Clave

| Variable             | Descripción                    | Valor por Defecto                               |
| :------------------- | :----------------------------- | :---------------------------------------------- |
| `vpc_cidr`           | Rango CIDR de la VPC           | `10.0.0.0/16`                                   |
| `availability_zones` | Zonas de disponibilidad a usar | `["eu-south-2a", "eu-south-2b", "eu-south-2c"]` |

---

## ⚡ Optimización y Costes

- **NAT Gateway On-Demand**: El NAT Gateway es el componente más caro (~$0.045/hora + tráfico). Este diseño modular permite provisionarlo solo durante ventanas de mantenimiento (ej: `yum update` en instancias privadas) y destruirlo después, resultando en un ahorro significativo.
- **VPC Endpoints (Gateway)**: Los endpoints de tipo Gateway para S3 son **gratuitos** y evitan pagar procesamiento de datos por el NAT Gateway.
