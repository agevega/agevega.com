# Project: agevega.com

## 🧠 Instrucciones Generales

- **Rol**: Ingeniero DevOps Senior.
- **Idioma**: Español para documentación. Ingles para código y comentarios en el código.
- **Estilo**: Conciso, técnico, directo. Evitar explicaciones obvias.
- **Filosofía del Proyecto**:
  - **Simplicidad**: Menos es más. Mantenibilidad sobre complejidad.
  - **AWS Nativo**: Uso de servicios gestionados de AWS (IaaS/CaaS).
  - **IaC Total**: Toda la infraestructura se define en Terraform. Cero cambios manuales en consola.
  - **Commits**: Nunca realizar commits. El usuario es el único responsable de versionar el código.

## 🌍 Arquitectura Global

- **Monorepo**: Frontend y Infraestructura en un mismo repositorio.
- **Despliegue**:
  - CI/CD vía GitHub Actions.
  - Frontend empaquetado en Docker -> ECR -> EC2 Bastion / Nginx.
  - Infraestructura gestionada por Terraform (Backend S3 remoto).
- **Seguridad Perimetral**:
  - **CloudFront**: Terminación SSL (HTTPS) y Caché.
  - **WAF**: AWS Managed Rules (Despliegue opcional por coste).
  - **Assets Privados**: S3 Bucket integrado en CloudFront con OAC.
  - **EC2**: Aislado. Solo accesible vía CloudFront (Security Group restringido a Prefix List) y SSH (IP whitelist).
  - **Protocolo**: HTTPS (Viewer) -> HTTP (Origin) para evitar conflictos SNI.

---

## 🎨 Contexto: Frontend (`/frontend`)

### 🛠 Stack Tecnológico

- **Framework**: Astro v5 (Static Site Generation).
- **Estilo**: TailwindCSS v3.
- **Build**: Docker (Node -> Nginx).

### 📏 Guías de Desarrollo

- **Zero JS**: Mantenlo estático. Usa "Astro Islands" (client:load) solo si es imprescindible.
- **Componentes**: Pequeños, atómicos y reutilizables.
- **Rendimiento**: Prioriza Core Web Vitals. Optimiza imágenes y fuentes.
- **Docker**: El Dockerfile debe ser multi-stage para minimizar el tamaño final de la imagen.

---

## ☁️ Contexto: Infraestructura (`/infra`)

### 🛠 Stack Tecnológico

- **IaC**: Terraform.
- **Cloud**: AWS (Región: `eu-south-2` - Madrid).

### 📏 Guías de Desarrollo

- **Estructura**: Módulos numerados (e.g., `01-networking`, `02-bastion-EC2`).
- **Convenciones**:
  - Recursos: `snake_case`.
  - Variables: Siempre incluir `description` y `type`.
- **Seguridad**:
  - Least Privilege en IAM Roles.
  - Security Groups estrictos (Whitelisting).
- **Recursos Principales**:
  - **VPC**: 3 capas (Public, Private, Data).
