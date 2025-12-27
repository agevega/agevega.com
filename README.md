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

- **Infraestructura como Código (IaC):** Todo el entorno se define y provisiona mediante Terraform, evitando configuraciones manuales irreproducibles.
- **Security First:** Implementación de auditoría (CloudTrail), cumplimiento de configuración (AWS Config) y principios de mínimo privilegio desde el inicio.
- **Soberanía:** Control granular sobre la red y la distribución de contenido, evitando plataformas PaaS "caja negra" en favor de una arquitectura AWS nativa.

---

## 🏗 Arquitectura del Sistema

La solución se compone de dos capas principales: Aplicación y Plataforma.

### 1. Frontend (Aplicación)

Desarrollado con **Astro** para generar un sitio puramente estático (SSG). Esto garantiza:

- Alto rendimiento (Zero JS por defecto).
- Seguridad (superficie de ataque reducida al no haber servidor de aplicaciones).
- Costes operativos mínimos (alojamiento en S3 + CloudFront).

### 2. Infraestructura (Plataforma)

El entorno de despliegue en AWS se gestiona en la carpeta `infra/` y comprende:

- **Compute & Networking:** VPC personalizada en la región `eu-south-2` (Madrid) con segmentación de subredes (Públicas/Privadas/Database).
- **Artifact Registry:** AWS ECR para almacenar las imágenes Docker del frontend.
- **Distribución:** CloudFront como CDN global, sirviendo contenido estático y enrutando tráfico dinámico.
- **Seguridad y Gestión:**
  - Autenticación OIDC para despliegues seguros desde GitHub Actions.
  - Logs de auditoría centralizados y reglas de AWS Config.
  - Gestión de dominios (Route53) y certificados SSL/TLS (ACM & Let's Encrypt).

---

## 🛠 Stack Tecnológico

| Capa         | Tecnología                  | Función                                               |
| :----------- | :-------------------------- | :---------------------------------------------------- |
| **Frontend** | **Astro** + **TailwindCSS** | Desarrollo de interfaz y generación de contenido.     |
| **IaC**      | **Terraform**               | Provisión y gestión del estado de la infraestructura. |
| **Cloud**    | **AWS**                     | Proveedor de nube (S3, CloudFront, VPC, IAM, etc.).   |
| **CI/CD**    | **GitHub Actions**          | Build & Push a ECR, Despliegue a EC2.                 |

---

## 📁 Estructura del Repositorio

```bash
agevega.com/
├── .github/                # CI/CD Workflows
│   └── workflows/
├── frontend/               # Aplicación web (Astro + Tailwind)
│   ├── src/                # Código fuente
│   └── package.json        # Dependencias
├── infra/                  # Definición de infraestructura
│   ├── terraform/          # Código HCL de Terraform
│   │   ├── 00-setup/       # Bootstrap (S3+Dynamo) + Auditoría
│   │   ├── 01-networking/  # Red (VPC 3-tier)
│   │   ├── 02-bastion-EC2/ # Bastion Host (Split Architecture)
│   │   └── 03-ECR/         # Registry de contenedores
│   └── changelog/          # Registro de cambios de infraestructura
├── public/                 # Archivos estáticos globales
└── scripts/                # Scripts de utilidad (Certificados, Despliegue)
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
3.  **Manual (Opcional)**: Se puede forzar un despliegue manual (`workflow_dispatch`) si es necesario rollbackear o redesplegar una versión específica.

> [!NOTE]
> Los scripts subyacentes `scripts/01_deploy_frontend.sh` y `scripts/00_generate_cert.sh` se ejecutan automáticamente en el servidor durante el despliegue, pero pueden usarse manualmente en caso de debug.

### Despliegue de Infraestructura

Los cambios en la nube se aplican mediante Terraform.

```bash
cd infra/terraform/<modulo>
terraform init
terraform plan
terraform apply
```

---

## 🗺 Roadmap

Estado actual de las tareas principales y evolución prevista:

- [x] **Seguridad y Observabilidad**: CloudTrail y AWS Config activos.
- [x] **Infraestructura Core**: Configuración base de AWS, VPC y gestión de estado Terraform.
- [x] **Frontend Base**: Proyecto Astro inicializado.
- [x] **Automatización CI/CD**: Pipeline de despliegue continuo (Build, Push to ECR, Deploy to EC2).
- [x] **Containerización**: Empaquetado de la aplicación con Docker y optimización con Nginx.
- [ ] **WAF y Seguridad Perimetral**: Reglas de filtrado en CloudFront.
- [ ] **Funcionalidad Backend**: Implementación serverless para formulario de contacto.

---

## 📄 Licencia

© Alejandro Vega. Este proyecto es open source bajo la licencia [MIT](./LICENSE).

---

## 📬 Autor y Contacto

**Alejandro Vega** · 🌐 [agevega.com](https://agevega.com) · 💼 [LinkedIn](https://www.linkedin.com/in/alejandro-vega94/) · ✉️ [agevega@gmail.com](mailto:agevega@gmail.com)

---
