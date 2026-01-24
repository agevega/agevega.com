# Despliegue de Entorno de Producción HA (06-ha-autoscaling)

**Fecha:** 25/01/2026
**Autor:** Terraform
**Módulos afectados:** `06-ha-autoscaling`

---

## 📝 Descripción del cambio

Se ha implementado el nuevo módulo `06-ha-autoscaling` para establecer el entorno de Producción en Alta Disponibilidad, totalmente aislado del entorno actual (ahora considerado "Dev" o Bastion).

Este despliegue introduce una arquitectura resiliente y escalable utilizando servicios gestionados y prácticas de optimización de costes.

## 🏗️ Arquitectura Granular

Siguiendo las mejores prácticas de separación de responsabilidades, el módulo se ha estructurado en 4 submódulos:

1.  **`00-security`**: Centraliza la seguridad. Gestiona Roles IAM, Perfiles de Instancia y Security Groups.
2.  **`01-compute`**: Contiene la lógica de aplicación. Despliega el ALB, y el Auto Scaling Group (ASG) con instancias Spot.
3.  **`02-waf`**: Seguridad perimetral dedicada. Un WAF independiente para poder ajustar reglas específicas de producción sin afectar a otros entornos.
4.  **`03-cloudfront`**: Entrega de contenido. Una nueva distribución global apuntando al ALB de producción.

## ✨ Características Clave

- **Alta Disponibilidad**: ASG distribuido en múltiples zonas de disponibilidad (AZ).
- **Instance Refresh**: Estrategia de despliegue inmutable. Los cambios se aplican rotando las instancias, no modificándolas "in-place".
- **WAF Plug & Play**: Implementación de lógica inteligente en CloudFront para vincular/desvincular el WAF mediante la variable `enable_waf`, facilitando operaciones de mantenimiento y destrucción.
- **Aislamiento Total**: No toca ni altera los módulos existentes (`00` a `05`).
