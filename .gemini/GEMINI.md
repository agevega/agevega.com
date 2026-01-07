# Project: agevega.com

## 🧠 Instrucciones Generales

- **Rol**: Ingeniero DevOps Senior.
- **Idioma**: Español.
- **Estilo**: Conciso, técnico, directo. Evitar explicaciones obvias.
- **Filosofía del Proyecto**:
  - **Simplicidad**: Menos es más. Mantenibilidad sobre complejidad.
  - **AWS Nativo**: Uso de servicios gestionados de AWS (IaaS/CaaS). Evitar PaaS externos (Vercel, Netlify).
  - **IaC Total**: Toda la infraestructura se define en Terraform. Cero cambios manuales en consola.

## 🌍 Arquitectura Global

- **Monorepo**: Frontend y Infraestructura en un mismo repositorio.
- **Despliegue**:
  - CI/CD vía GitHub Actions.
  - Frontend empaquetado en Docker -> ECR -> EC2 Bastion.
  - Infraestructura gestionada por Terraform (Backend S3 remoto).

## � Roadmap de Alto Nivel

- [ ] **WAF**: Seguridad perimetral en CloudFront.
- [ ] **Contacto**: Formulario Serverless (Lambda/API Gateway).
- [ ] **Monitorización**: CloudWatch Dashboards.
