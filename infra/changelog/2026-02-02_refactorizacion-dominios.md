# Refactorización de Dominios y Estandarización de Infraestructura

**Fecha:** 02/02/2026  
**Autor:** Terraform  
**Módulos afectados:** `99-domain`, `02-shared-resources`, `04-bastion-host`, `05-high-availability`

---

## 📝 Descripción del cambio

Se ha reorganizado la estructura del proyecto para centralizar la gestión de dominios y mejorar el orden lógico de despliegue, además de una estandarización masiva de etiquetado ("tagging").

## 🏗️ Cambios en Infraestructura

### Nuevo Módulo `99-domain`

Se ha creado un módulo dedicado para la gestión de todo lo relacionado con DNS y Certificados SSL, moviendo componentes que antes estaban dispersos o mal ubicados.

Estructura final:

1.  **`00-dns-zone`**: Hosted Zone principal (`agevega.com`).
2.  **`01-acm-certificate`**: Generación del certificado SSL (Movido desde `02-shared-resources`).
3.  **`02-acm-validation`**: Validación DNS del certificado.

### Clarificación de Registros DNS (`A/Alias`)

Se hace explícito el modelo de responsabilidad compartida para los registros DNS:

- **`99-domain`**: Gestiona solo la Zona y la Validación de Certificados (Infraestructura Base).
- **`04-bastion-host/05-dns-record`**: Gestiona el subdominio `dev.agevega.com`.
- **`05-high-availability/04-dns-record`**: Gestiona el dominio raíz `agevega.com` y `www`.

### Reorganización de `02-shared-resources`

Tras mover los certificados, se ha reordenado este módulo para eliminar huecos numéricos:

- **Eliminado**: `01-acm-certificates` (Movido a `99-domain`).
- **Renombrado**: `03-ecr-repositories` -> `01-ecr-repositories`.

### Auditoría y Estandarización de Tags

Se ha realizado una auditoría exhaustiva en los más de 20 submódulos del proyecto.

- **Variables.tf**: Se ha garantizado que el tag `Module` en `var.common_tags` coincida exactamente con la ruta del directorio (ej: `99-domain/01-acm-certificate`).
- **Main.tf**: Se han eliminado todos los tags `Module` hardcodeados en los recursos, forzando el uso de la variable común para evitar discrepancias.

## 📋 Resumen de Acciones

- [x] Mover `02-shared-resources/01-acm-certificates` a `99-domain`.
- [x] Renombrar carpetas a singular (`certificates` -> `certificate`) por consistencia.
- [x] Renombrar `03-ecr-repositories` a `01-ecr-repositories`.
- [x] Actualizar todas las referencias de estado remoto (`backend.tf` y `data.tf`) en módulos dependientes (`bastion`, `ha`, `validation`).
