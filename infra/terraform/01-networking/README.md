# 01-networking

Este directorio containe la infraestructura de red dividida en **submódulos** para facilitar la gestión de costes y actualizaciones.

## 📂 Submódulos

### 1. [00-vpc-core](./00-vpc-core)

- **Descripción**: Despliega la VPC, Subredes (Públicas, Privadas, DB), Internet Gateway y Tablas de Rutas base.
- **Uso**: Siempre activo. Es el cimiento de la infraestructura.

### 2. [01-nat-gateway](./01-nat-gateway)

- **Descripción**: Despliega el NAT Gateway y la Elastic IP asociada. Añade rutas `0.0.0.0/0` a las tablas privadas.
- **Uso**: **Opcional**. Desplegar solo cuando las instancias privadas necesiten acceso a Internet (ej: actualizaciones). Destruir para ahorrar costes (~33€/mes).

### 3. [02-vpc-endpoints](./02-vpc-endpoints)

- **Descripción**: Endpoints de VPC para acceso interno a servicios AWS.
- **Recursos**: S3 Gateway Endpoint.
- **Uso**: Recomendado para permitir acceso a S3 privado sin salir a Internet.

## 🚀 Guía de Despliegue

El orden de despliegue es estricto debido a las dependencias de estado remoto:

1.  **Core (Obligatorio)**:

    ```bash
    cd 00-vpc-core
    terraform init
    terraform apply
    ```

2.  **Endpoints (Recomendado)**:

    ```bash
    cd ../02-vpc-endpoints
    terraform init
    terraform apply
    ```

3.  **NAT Gateway (Solo bajo demanda)**:
    ```bash
    cd ../01-nat-gateway
    terraform init
    terraform apply
    ```
