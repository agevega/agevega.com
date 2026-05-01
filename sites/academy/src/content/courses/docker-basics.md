---
title: Docker desde cero — Contenedores para DevOps
description: Aprende a crear, ejecutar y publicar contenedores Docker. Desde el primer Dockerfile hasta compose multi-servicio y buenas prácticas de seguridad en imágenes.
youtubeId: dQw4w9WgXcQ
category: devops
tags: [docker, contenedores, devops, dockerfile, compose]
order: 2
publishedAt: 2024-02-10
difficulty: beginner
resources:
  - label: Repositorio con ejemplos del curso
    url: https://github.com/agevega/academy-docker-basics
  - label: Documentación oficial de Docker
    url: https://docs.docker.com
  - label: Docker Hub — registro público de imágenes
    url: https://hub.docker.com
  - label: Mejores prácticas para Dockerfiles (Docker docs)
    url: https://docs.docker.com/develop/develop-images/dockerfile_best-practices/
---

## ¿Por qué Docker?

Docker resuelve el clásico problema de "en mi máquina funciona". Un contenedor empaqueta la aplicación junto con todas sus dependencias — sistema operativo incluido — garantizando que el entorno de desarrollo, test y producción sean idénticos.

## Tu primer Dockerfile

```dockerfile
# Imagen base con Node.js
FROM node:20-alpine

# Directorio de trabajo dentro del contenedor
WORKDIR /app

# Copiar dependencias primero (aprovecha el caché de capas)
COPY package*.json ./
RUN npm install --omit=dev

# Copiar el código de la aplicación
COPY . .

# Exponer el puerto de la aplicación
EXPOSE 3000

# Comando de arranque
CMD ["node", "src/index.js"]
```

## Comandos esenciales

```bash
# Construir la imagen
docker build -t mi-app:1.0 .

# Ejecutar el contenedor
docker run -p 3000:3000 mi-app:1.0

# Ver contenedores en ejecución
docker ps

# Ver logs
docker logs <container-id>

# Entrar al contenedor
docker exec -it <container-id> sh

# Detener y eliminar
docker stop <container-id>
docker rm <container-id>
```

## Docker Compose para desarrollo

Con Compose puedes definir y ejecutar aplicaciones multi-contenedor:

```yaml
# docker-compose.yml
services:
  app:
    build: .
    ports:
      - "3000:3000"
    environment:
      - DATABASE_URL=postgres://user:pass@db:5432/mydb
    depends_on:
      - db

  db:
    image: postgres:16-alpine
    volumes:
      - postgres_data:/var/lib/postgresql/data
    environment:
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=pass
      - POSTGRES_DB=mydb

volumes:
  postgres_data:
```

```bash
# Arrancar todos los servicios
docker compose up -d

# Ver logs de todos
docker compose logs -f

# Parar todo
docker compose down
```

## Seguridad en imágenes Docker

Puntos clave para imágenes seguras:

1. **Usar imágenes base mínimas**: `alpine` o `distroless` en lugar de `ubuntu`
2. **No ejecutar como root**: añadir `USER nonroot` en el Dockerfile
3. **Escanear vulnerabilidades**: `docker scout cves mi-app:1.0`
4. **Multi-stage builds**: reducir la superficie de ataque en la imagen final

```dockerfile
# Multi-stage build — imagen final sin herramientas de compilación
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:20-alpine AS runtime
WORKDIR /app
# Solo el usuario sin privilegios
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
USER appuser
EXPOSE 3000
CMD ["node", "dist/index.js"]
```
