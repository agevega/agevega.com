# 🧩 2025-12-07 — Despliegue de repositorio ECR (Módulo 03)

### 🗂️ Descripción

Despliegue del módulo `03-ECR` en `infra/terraform/03-ECR/`. Este módulo provisiona el registro de contenedores necesario para almacenar las imágenes Docker del frontend antes de su despliegue en ECS/EC2.

---

## 📦 Amazon ECR

### ⚙️ Acciones realizadas

- Creado repositorio **`agevegacom-frontend`**.
- Configuración aplicada:
  - **Escaneo de vulnerabilidades**: Activado en cada _push_.
  - **Mutabilidad de etiquetas**: Permitida (para facilitar actualizaciones de `latest` en entornos de dev).
- **Ciclo de Vida (Cost Optimization)**:
  - Regla automática para **rotar imágenes**.
  - Se conservan solo las **últimas 10 imágenes**.
  - Las imágenes más antiguas se expiran y eliminan automáticamente para evitar costes de almacenamiento a largo plazo.

---

## 🎯 Motivo

- Centralizar el almacenamiento de artefactos (imágenes Docker) en un servicio gestionado seguro.
- Preparar el terreno para el pipeline de CI/CD que construirá y subirá la imagen del frontend.
- Mantener el control de costes evitando la acumulación infinita de imágenes obsoletas.

---

## 💰 Coste estimado mensual

| Recurso                    | Estimado mensual | Notas                                                                       |
| :------------------------- | :--------------- | :-------------------------------------------------------------------------- |
| **Almacenamiento ECR**     | ~0.10 €          | Para ~500MB de imágenes almacenadas.                                        |
| **Transferencia de datos** | Variable         | Coste por descarga hacia Internet (gratis dentro de la misma región a EC2). |

**Total estimado:** ~0.10 €/mes
