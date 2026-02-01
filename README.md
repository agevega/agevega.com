# 🚀 Agevega.com

![AWS](https://img.shields.io/badge/AWS-232F3E?style=for-the-badge&logo=amazon-aws&logoColor=white)
![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)
![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)
![Nginx](https://img.shields.io/badge/nginx-%23009639.svg?style=for-the-badge&logo=nginx&logoColor=white)
![Astro](https://img.shields.io/badge/astro-%232C2052.svg?style=for-the-badge&logo=astro&logoColor=white)
![TypeScript](https://img.shields.io/badge/typescript-%23007ACC.svg?style=for-the-badge&logo=typescript&logoColor=white)
![TailwindCSS](https://img.shields.io/badge/tailwindcss-%2338B2AC.svg?style=for-the-badge&logo=tailwind-css&logoColor=white)
![Node.js](https://img.shields.io/badge/node.js-6DA55F?style=for-the-badge&logo=node.js&logoColor=white)
![Python](https://img.shields.io/badge/python-3670A0?style=for-the-badge&logo=python&logoColor=ffdd54)
![GitHub Actions](https://img.shields.io/badge/github%20actions-%232671E5.svg?style=for-the-badge&logo=githubactions&logoColor=white)

**Este repositorio** orquesta el ciclo de vida completo de `agevega.com`, desde el código fuente del frontend hasta la infraestructura subyacente en **AWS**.

Se ha construido una plataforma **AWS Cloud-Native** siguiendo los principios de **Seguridad, Automatización, Resiliencia, Escalabilidad, Granularidad, Observabilidad y Optimización de Costes (FinOps)**. Todo provisionado 100% como código **(IaC)**.

---

## 💡 Filosofía del Proyecto

Este proyecto se aborda con una **perspectiva de ingeniería de infraestructura**, demostrando que la robustez y la escalabilidad no están reñidas con el bajo coste. Se priorizan prácticas como:

- **Seguridad**: Modelo **Zero Trust** donde cada capa (WAF, CloudFront, ALB, EC2) verifica explícitamente a su predecesora.
- **Inmutabilidad y Automatización**: Cero cambios manuales ("ClickOps"). Desde la red hasta la capa de aplicación, todo nace y evoluciona mediante **Terraform** y **CI/CD**.
- **Resiliencia y Escalabilidad**: Diseño horizontal tolerante a fallos distribuido en múltiples **Zonas de Disponibilidad (AZs)** y protegido globalmente en el Edge.
- **Granularidad**: Módulos de infraestructura acotados y desacoplados para facilitar cambios ordenados y seguros.
- **FinOps**: Uso de **Spot Instances** y procesadores **Graviton (ARM64)** para mantener un entorno de Alta Disponibilidad a menor coste.

---

## 🏗 Arquitectura del Sistema

Diseño cloud-native orientado a la optimización de costes y alta disponibilidad, siguiendo una estrategia dual para equilibrar costes y disponibilidad, apoyada en componentes serverless globales.

### 🌐 Infraestructura (AWS)

La red se despliega sobre una **VPC 3-Tier** personalizada, segmentando el tráfico en subredes públicas y privadas.

#### 1. Entorno de Desarrollo (Bastion)

- **Compute**: Instancia `t4g.nano` (Linux 2023).
- **Seguridad**: Acceso administrativo restringido mediante Security Groups (SSH Whitelist).
- **Función**: Punto de entrada a la red privada y entorno de pruebas.

#### 2. Entorno de Producción (High Availability)

- **Compute**: Clúster EC2 elástico gestionado por un **Auto Scaling Group (ASG)** con **instancias Spot** para eficiencia de costes.
- **Routing**: **Application Load Balancer (ALB)** interno que distribuye el tráfico hacia el ASG y solo permite peticiones validadas desde la CDN.

### 💻 Stack de Aplicación

| Capa         | Tecnología                   | Función                                            |
| :----------- | :--------------------------- | :------------------------------------------------- |
| **Frontend** | **Astro** + **TailwindCSS**  | Interfaz estática (SSG) de alto rendimiento.       |
| **Runtime**  | **Docker** + **Nginx**       | Contenedorización y servidor web optimizado.       |
| **Backend**  | **Lambda** + **API Gateway** | Lógica serverless (Python).                        |
| **IaC**      | **Terraform**                | Definición declarativa de toda la infraestructura. |
| **Cloud**    | **AWS**                      | S3, VPC, ECR, CloudFront, WAF, IAM, EC2...         |
| **CI/CD**    | **GitHub Actions**           | Automatización de Build, Push y Deploy.            |

### 🔐 Seguridad

- **Content Delivery**: **CloudFront** con **OAC** (Origin Access Control) para servir assets desde S3.
- **Edge Security**: **AWS WAF** con reglas gestionadas para mitigación de ataques comunes.
- **Identity**: Gestión de certificados SSL/TLS mediante **ACM** y resolución de dominios en **Route53**.

---

## 📁 Estructura del Repositorio

```bash
agevega.com/
├── .gemini/                       # Contexto y Memoria del Proyecto
├── .github/                       # CI/CD Workflows
│   └── workflows/
├── frontend/                      # Aplicación web (Astro + Tailwind)
│   ├── src/                       # Código fuente
│   ├── public/                    # Archivos estáticos
│   └── Dockerfile                 # Definición de la imagen
├── infra/                         # Definición de infraestructura
│   ├── terraform/                 # Código HCL de Terraform
│   │   ├── 00-setup/              # Bootstrap, Auditoría y Budgets
│   │   ├── 01-networking/         # VPC 3-Tier (Core, NAT, Endpoints)
│   │   ├── 02-shared-resources/   # ECR, ACM, S3 Assets, SSH Keys
│   │   ├── 03-backend-serverless/ # Lambda Contact & SES
│   │   ├── 04-bastion-host/       # Entorno Dev & Acceso SSH
│   │   └── 05-high-availability/  # Entorno Prod (ASG + ALB)
│   └── changelog/                 # Registro de cambios
└── scripts/                       # Scripts de utilidad
```

---

## 🚀 Uso y Despliegue

### Desarrollo Localhost (Frontend)

Para trabajar en el diseño y contenido del sitio web:

```bash
# Iniciar servidor de desarrollo en http://localhost:4321
cd frontend
npm install
npm run dev
```

### Despliegue de Aplicación (CI/CD)

El proyecto cuenta con workflows de GitHub Actions para gestionar el ciclo de vida de la aplicación:

1.  **Build & Push**: Al pushear un tag (`v*.*.*`), se construye la imagen y se sube a **AWS ECR**.
2.  **Deploy Automático**: El workflow anterior dispara automáticamente el despliegue (`01-deploy-to-ec2`), actualizando el Bastion Host con la nueva versión.
3.  **Manual (Opcional)**: Se puede forzar un despliegue manual si es necesario rollbackear o redesplegar una versión específica.

> [!NOTE]
> Los scripts subyacentes `scripts/01_deploy_frontend.sh` y `scripts/00_generate_cert.sh` se ejecutan automáticamente en el servidor durante el despliegue, pero pueden usarse manualmente en caso de debug.

### Despliegue de Infraestructura

Los cambios en AWS se aplican mediante Terraform. Para más detalles, consulta la [documentación de Infraestructura](./infra/README.md).

---

## 🗺 Roadmap

Estado actual de las tareas principales y evolución prevista:

- [x] **Seguridad y Observabilidad**: CloudTrail, AWS Config y Budgets activos.
- [x] **Infraestructura Core**: VPC 3-Tier y gestión de estado remoto.
- [x] **Frontend & CI/CD**: Astro, Docker y Pipelines de GitHub Actions.
- [x] **Serverless Backend**: API Gateway + Lambda para contacto.
- [x] **Alta Disponibilidad**: Cluster de producción con Spot Instances y Autoscaling.
- [x] **Optimización de Costes**: Migración a ARM64 y WAF 'Plug & Play'.
- [x] **Refactorización Modular**: Organización granular de IaC.

---

## 📄 Licencia

© Alejandro Vega. Este proyecto es open source bajo la licencia [MIT](./LICENSE).

---

## 📬 Autor y Contacto

**Alejandro Vega** · 🌐 [agevega.com](https://agevega.com) · 💼 [LinkedIn](https://www.linkedin.com/in/alejandro-vega94/) · ✉️ [agevega@gmail.com](mailto:agevega@gmail.com)

---
