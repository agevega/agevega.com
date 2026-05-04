# 💻 Landing - Agevega.com

Sitio principal de `agevega.com` (landing page del portfolio). Aplicación estática (SSG) de alto rendimiento construida con **Astro 6** y optimizada para despliegue en contenedores **Docker**. Vive en `sites/landing/` dentro del monorepo.

## 🛠 Tech Stack

- **Framework**: [Astro v6](https://astro.build/) (Static Site Generation).
- **Styling**: [Tailwind CSS v4](https://tailwindcss.com/) (CSS-first, `@theme {}` en `global.css`).
- **Package Manager**: [Bun](https://bun.sh/) 1.1+.
- **Language**: TypeScript & Vanilla JS (Zero JS approach).
- **Runtime**: Nginx (Alpine) sobre Docker con HTTPS (self-signed).

## 🏗 Arquitectura de Runtime

El sitio no es solo HTML estático; incluye una capa de "consciencia de infraestructura" que se ejecuta al iniciar el contenedor.

### 1. Docker & Nginx

La imagen final (`nginx:alpine`) es extremadamente ligera (<30MB).

- **Build Stage**: `oven/bun:1.1` compila el sitio Astro (`bun run build`).
- **Runtime Stage**: Nginx sirve los archivos estáticos desde `/usr/share/nginx/html` con HTTPS (puerto 443).

### 2. Infra-Awareness (`meta.json`)

El script [`docker-entrypoint.sh`](./docker-entrypoint.sh) se ejecuta al iniciar el contenedor y consulta el **AWS IMDSv2** (Instance Metadata Service) para generar un archivo `meta.json` en tiempo real.

Esto permite que la web muestre (en la sección "About This Web") información real sobre dónde se está ejecutando:

- **Provider**: AWS (o Local).
- **Region & AZ**: e.g., `eu-south-2a`.
- **Instance Type**: e.g., `t4g.nano` (Spot).
- **Architecture**: `aarch64` (Graviton2).

## 🚀 Desarrollo Local

### Requisitos

- [Bun](https://bun.sh/) 1.1+

### Comandos

```bash
# Instalar dependencias
bun install

# Iniciar servidor de desarrollo (Hot Reload)
# Accesible en http://localhost:4321
bun run dev

# Construir producción (para probar build errors)
bun run build

# Previsualizar build de producción
bun run preview

# Tests (Vitest)
bun run test
```

## 🐳 Docker Local

Para simular el entorno de producción exacto:

```bash
# Construir la imagen
docker build --build-arg PUBLIC_API_URL=https://stub.example.com --build-arg PUBLIC_APP_VERSION=test -t agevega-landing .

# Correr el contenedor
docker run -p 8080:443 agevega-landing

# Abrir https://localhost:8080 (aceptar cert self-signed)
```

> **Nota:** En local, el script de entrypoint detectará que no está en AWS y rellenará `meta.json` con valores "Local", evitando bloqueos de timeout.

## 📂 Archivos Clave

- **[`astro.config.mjs`](./astro.config.mjs)**: Configuración del compilador Astro + plugin `@tailwindcss/vite`.
- **[`src/styles/global.css`](./src/styles/global.css)**: Design tokens (`@theme {}`), animaciones y estilos globales.
- **[`nginx.conf`](./nginx.conf)**: Configuración del servidor web (HTTPS, caching, gzip, rutas SSG).
- **[`docker-entrypoint.sh`](./docker-entrypoint.sh)**: Lógica de arranque y obtención de metadatos.
- **[`Dockerfile`](./Dockerfile)**: Build multi-stage (`oven/bun:1.1` → `nginx:alpine`).

Ver [CLAUDE.md](CLAUDE.md) para convenciones del proyecto y [TESTING.md](TESTING.md) para la estrategia de tests.
