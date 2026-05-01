# AgeVega Academy — Frontend

Aplicación Astro 6 (SSG) del sitio de cursos. Ver el [README raíz](../README.md) para instrucciones completas de arranque y despliegue.

## Comandos rápidos

```bash
bun install        # Instalar dependencias
bun run dev        # Dev server → http://localhost:4321
bun run build      # Build estático a dist/
bun run preview    # Preview del build
bun run test       # Vitest — schema validation
```

## Docker

```bash
docker build -t academy-frontend .
docker run -p 80:80 academy-frontend
```

Ver [CLAUDE.md](CLAUDE.md) para convenciones del proyecto y [TESTING.md](TESTING.md) para la estrategia de tests.
