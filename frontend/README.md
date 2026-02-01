# 💻 Frontend - agevega.com

Aplicación estática (SSG) de alto rendimiento construida con **Astro** y optimizada para despliegue en contenedores **Docker**.

## 🛠 Tech Stack

- **Framework**: [Astro v5](https://astro.build/) (Static Site Generation).
- **Styling**: [TailwindCSS v3](https://tailwindcss.com/).
- **Language**: TypeScript & Vanilla JS (Zero JS approach).
- **Runtime**: Nginx (Alpine) sobre Docker.

## 🏗 Arquitectura de Runtime

El frontend no es solo HTML estático; incluye una capa de "consciencia de infraestructura" que se ejecuta al iniciar el contenedor.

### 1. Docker & Nginx

La imagen final (`nginx:alpine`) es extremadamente ligera (<30MB).

- **Build Stage**: Node.js compila el sitio Astro (`npm run build`).
- **Runtime Stage**: Nginx sirve los archivos estáticos desde `/usr/share/nginx/html`.

### 2. Infra-Awareness (`meta.json`)

El script [`docker-entrypoint.sh`](./docker-entrypoint.sh) se ejecuta al iniciar el contenedor y consulta el **AWS IMDSv2** (Instance Metadata Service) para generar un archivo `meta.json` en tiempo real.

Esto permite que la web muestre (en el footer o sección "About This Web") información real sobre dónde se está ejecutando:

- **Provider**: AWS (o Local).
- **Region & AZ**: e.g., `eu-south-2a`.
- **Instance Type**: e.g., `t4g.nano` (Spot).
- **Architecture**: `aarch64` (Graviton2).

## 🚀 Desarrollo Local

### Requisitos

- Node.js 20+
- npm

### Comandos

```bash
# Instalar dependencias
npm install

# Iniciar servidor de desarrollo (Hot Reload)
# Accesible en http://localhost:4321
npm run dev

# Construir producción (para probar build errors)
npm run build

# Previsualizar build de producción
npm run preview
```

## 🐳 Docker Local

Para simular el entorno de producción exacto:

```bash
# Construir la imagen
docker build -t agevega-frontend .

# Correr el contenedor
docker run -p 8080:80 agevega-frontend
```

> **Nota:** En local, el script de entrypoint detectará que no está en AWS y rellenará `meta.json` con valores "Local", evitando bloqueos de timeout.

## 📂 Archivos Clave

- **[`astro.config.mjs`](./astro.config.mjs)**: Configuración del compilador Astro.
- **[`nginx.conf`](./nginx.conf)**: Configuración del servidor web (caching, gzip, rutas).
- **[`docker-entrypoint.sh`](./docker-entrypoint.sh)**: Lógica de arranque y obtención de metadatos.
