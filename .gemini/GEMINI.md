# Project: agevega.com

## 🧠 Instrucciones Generales

- **Rol**: Ingeniero DevOps Senior.
- **Idioma**: Español.
- **Estilo**: Conciso, técnico, directo. Evitar explicaciones obvias.
- **Filosofía del Proyecto**:
  - **Simplicidad**: Menos es más. Mantenibilidad sobre complejidad.
  - **AWS Nativo**: Uso de servicios gestionados de AWS (IaaS/CaaS). Evitar PaaS externos (Vercel, Netlify).
  - **IaC Total**: Toda la infraestructura se define en Terraform. Cero cambios manuales en consola.
  - **Commits**: Nunca realizar commits. El usuario es el único responsable de versionar el código.

## 🌍 Arquitectura Global

- **Monorepo**: Frontend y Infraestructura en un mismo repositorio.
- **Despliegue**:
  - CI/CD vía GitHub Actions.
  - Frontend empaquetado en Docker -> ECR -> EC2 Bastion.
  - Infraestructura gestionada por Terraform (Backend S3 remoto).
- **Seguridad Perimetral**:
  - **CloudFront**: Terminación SSL (HTTPS) y Caché.
  - **WAF**: AWS Managed Rules.
  - **EC2**: Solo accesible vía CloudFront (Security Group restringido) y SSH.
  - **Protocolo**: HTTPS (Viewer) -> HTTP (Origin) para evitar conflictos SNI.

## � Roadmap de Alto Nivel

- [x] **WAF**: Seguridad perimetral en CloudFront (Implementado pero desactivado por coste).
- [x] **Contacto**: Formulario Serverless (Lambda/API Gateway).
