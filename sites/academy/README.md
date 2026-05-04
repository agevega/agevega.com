# AgeVega Academy

Aplicación Astro 6 (SSG) del sitio de cursos. Vive en `sites/academy/` dentro del monorepo. Ver el [README raíz](../../README.md) para visión general del repo.

## Comandos rápidos

```bash
bun install        # Instalar dependencias
bun run dev        # Dev server → http://localhost:4322 (set en astro.config.mjs)
bun run build      # Build estático a dist/
bun run preview    # Preview del build
bun run test       # Vitest — schema validation
```

## Docker

```bash
docker build -t agevega-academy .
docker run -p 8080:443 agevega-academy

# Then open https://localhost:8080 (accept self-signed cert)
```

Ver [CLAUDE.md](CLAUDE.md) para convenciones del proyecto y [TESTING.md](TESTING.md) para la estrategia de tests.
