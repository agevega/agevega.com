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
  - **WAF**: AWS Managed Rules (Provisionado pero desactivado por coste).
  - **Assets Privados**: S3 Bucket integrado en CloudFront con OAC (`05-cloudfront-WAF-S3`).
  - **EC2**: Aislado. Solo accesible vía CloudFront (Security Group restringido a Prefix List) y SSH (IP whitelist).
  - **Protocolo**: HTTPS (Viewer) -> HTTP (Origin) para evitar conflictos SNI.

## 📍 Roadmap de Alto Nivel

- [x] **WAF/CDN**: Distribución Global y Seguridad (CloudFront + WAF).
- [x] **Contacto**: Formulario Serverless (Lambda/API Gateway).
- [x] **Privacidad**: Hosting seguro de documentos (CV) vía S3 OAC.
