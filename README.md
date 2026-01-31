# 🌐 agevega.com

![AWS](https://img.shields.io/badge/AWS-232F3E?style=for-the-badge&logo=amazon-aws&logoColor=white)
![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)
![Astro](https://img.shields.io/badge/astro-%232C2052.svg?style=for-the-badge&logo=astro&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/github%20actions-%232671E5.svg?style=for-the-badge&logo=githubactions&logoColor=white)

Este repositorio contiene el código fuente y la definición de infraestructura para el sitio web personal de **Alejandro Vega**.

El proyecto funciona como un **monorepo** que centraliza tanto el desarrollo del frontend (landing page) como la gestión del ciclo de vida de la infraestructura en la nube (AWS) mediante código.

---

## 💡 Filosofía del Proyecto

Aunque el objetivo final es servir un sitio web estático, el proyecto se aborda con una **perspectiva de ingeniería de infraestructura**. Se priorizan prácticas como:

- **Infraestructura como Código (IaC):** Todo el entorno se define y provisiona mediante Terraform.
- **Security First:** Auditoría (CloudTrail), AWS Config y principios de mínimo privilegio.
- **Soberanía:** Arquitectura AWS nativa, evitando dependencias de plataformas PaaS.

---

## 🏗 Arquitectura del Sistema

Diseño cloud-native orientado a la optimización de costes y alta disponibilidad, siguiendo una estrategia dual para equilibrar costes y disponibilidad, apoyada en componentes serverless globales.

### 💻 Stack de Aplicación

- **Frontend**: **Astro** (SSG) y **TailwindCSS** para una entrega de contenido ultrarrápida con enfoque _Zero JS_.
- **Contenerización**: Imágenes **Docker** optimizadas con **Nginx**, gestionadas en **Amazon ECR** para despliegues sobre **EC2**.
- **Backend**: Lógica serverless mediante **AWS Lambda** (Python) y **API Gateway**.

### 🌐 Infraestructura (AWS)

La red se despliega sobre una **VPC 3-Tier** personalizada, segmentando el tráfico en subredes públicas y privadas.

#### 1. Entorno de Desarrollo (Bastion)

- **Compute**: Instancia `t4g.nano` (Linux 2023).
- **Seguridad**: Acceso administrativo restringido mediante Security Groups (SSH Whitelist).
- **Función**: Punto de entrada a la red privada y entorno de pruebas.

#### 2. Entorno de Producción (High Availability)

- **Compute**: Clúster EC2 elástico gestionado por un **Auto Scaling Group (ASG)** con **instancias Spot** para eficiencia de costes.
- **Routing**: **Application Load Balancer (ALB)** interno que distribuye el tráfico hacia el ASG y solo permite peticiones validadas desde la CDN.

### 🔐 Seguridad y Distribución

- **Content Delivery**: **CloudFront** con **OAC** (Origin Access Control) para servir assets desde S3.
- **Edge Security**: **AWS WAF** con reglas gestionadas para mitigación de ataques comunes.
- **Identity**: Gestión de certificados SSL/TLS mediante **ACM** y resolución de dominios en **Route53**.
- **CI/CD**: Pipelines automatizados en **GitHub Actions** para el build de imágenes y despliegues.

---

## 🛠 Stack Tecnológico

| Capa           | Tecnología                   | Función                                                     |
| :------------- | :--------------------------- | :---------------------------------------------------------- |
| **Frontend**   | **Astro** + **TailwindCSS**  | Desarrollo de interfaz "Zero JS" y generación estática.     |
| **IaC**        | **Terraform**                | Provisión y gestión del estado de la infraestructura.       |
| **Serverless** | **Lambda** + **API Gateway** | Backend y gestión de APIs.                                  |
| **Cloud**      | **AWS**                      | S3, CloudFront, VPC, SES, IAM, EC2...                       |
| **FinOps**     | **Spot Instances**           | Cómputo efímero de bajo coste (`t4g.nano`) para producción. |
| **CI/CD**      | **GitHub Actions**           | Build & Push a ECR, Despliegue a EC2 Fleet.                 |

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

### Desarrollo Local (Frontend)

Para trabajar en el diseño y contenido del sitio web:

```bash
# Navegar al directorio frontend
cd frontend

# Instalar dependencias
npm install

# Iniciar servidor de desarrollo en http://localhost:4321
npm run dev
```

### Despliegue (CI/CD)

El proyecto cuenta con workflows de GitHub Actions para gestionar el ciclo de vida de la aplicación:

1.  **Build & Push**: Al pushear un tag (`v*.*.*`), se construye la imagen y se sube a **AWS ECR**.
2.  **Deploy Automático**: El workflow anterior dispara automáticamente el despliegue (`01-deploy-to-ec2`), actualizando el Bastion Host con la nueva versión.
3.  **Manual (Opcional)**: Se puede forzar un despliegue manual si es necesario rollbackear o redesplegar una versión específica.

> [!NOTE]
> Los scripts subyacentes `scripts/01_deploy_frontend.sh` y `scripts/00_generate_cert.sh` se ejecutan automáticamente en el servidor durante el despliegue, pero pueden usarse manualmente en caso de debug.

### Despliegue de Infraestructura

Los cambios en la nube se aplican mediante Terraform.

```bash
cd infra/terraform/<modulo>/<submodulo>
terraform init
terraform plan
terraform apply
```

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
