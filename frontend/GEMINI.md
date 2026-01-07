# Contexto: Frontend (`/frontend`)

## 🛠 Stack Tecnológico

- **Framework**: Astro v5 (Static Site Generation).
- **Estilo**: TailwindCSS v3.
- **Build**: Docker (Node -> Nginx).

## 📏 Guías de Desarrollo

- **Zero JS**: Mantenlo estático. Usa "Astro Islands" (client:load) solo si es imprescindible.
- **Componentes**: Pequeños, atómicos y reutilizables.
- **Rendimiento**: Prioriza Core Web Vitals. Optimiza imágenes y fuentes.
- **Docker**: El Dockerfile debe ser multi-stage para minimizar el tamaño final de la imagen.
