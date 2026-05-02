# CLAUDE.md — landing

agevega.com landing site (`https://www.agevega.com/`). Personal portfolio of Alejandro Vega — Senior DevSecOps Engineer & Cloud Architect.
**Stack:** Astro 6 (SSG) + Tailwind v4 (CSS-first, no config file) + Bun, Docker/Nginx runtime with HTTPS + AWS IMDS metadata awareness.

## Monorepo context

This app lives at `agevega.com/sites/landing/`, sibling of `agevega.com/sites/academy/`. The monorepo at `agevega.com/` hosts one self-contained static site per subdomain under `sites/`. Conventions are documented in `agevega.com/sites/CONVENTIONS.md`.

- **Sites pattern.** Every subdomain gets its own directory under `sites/<name>/`. The parent dir is for grouping only — there is no shared `package.json`, no nx, no turborepo, no orchestration tool.
- **Self-contained.** Each app has its own `Dockerfile`, `nginx.conf`, package manager, and framework version. No shared lockfile.
- **Stack converged (post-2026-05-02 audit):** both landing and academy now run Astro 6 + Tailwind v4 + bun. Versions evolve per-app from this baseline.
- **Local dev port allocation.** Landing on `:4321` (Astro default), academy on `:4322` (set via `server.port` in academy's `astro.config.mjs`). Run in parallel without collision.
- **CI/CD scope.** The 3 deploy workflows (`00-generate-docker-image`, `01-deploy-bastion`, `02-deploy-production`) build & deploy this app to ECR `agevegacom-landing` and the EC2 ASG behind CloudFront. Tags `v*` apply repo-wide and trigger the landing pipeline only.

## Repository Structure

```
sites/landing/
├── src/
│   ├── components/         # Astro components (PascalCase)
│   │   ├── AboutSection.astro
│   │   ├── ArchitectureSection.astro
│   │   ├── ContactSection.astro
│   │   ├── ExperienceSection.astro
│   │   ├── Footer.astro
│   │   ├── HeroSection.astro
│   │   ├── LaboratorioSection.astro
│   │   ├── Navigation.astro
│   │   ├── ProjectsSection.astro
│   │   └── TechStackSection.astro
│   ├── layouts/
│   │   └── Layout.astro    # Base layout: SEO meta + skip-link + ambient glow + nav/footer
│   ├── pages/
│   │   ├── index.astro     # Home — hero + sections
│   │   ├── about.astro     # Bio
│   │   ├── about-this-web.astro  # Renders meta.json (IMDS-derived) — infra-awareness page
│   │   ├── contact.astro   # Contact form (POST to PUBLIC_API_URL)
│   │   ├── laboratory.astro
│   │   └── 404.astro       # Custom 404 page
│   ├── styles/
│   │   └── global.css      # Tailwind v4 @import + @theme tokens + @keyframes
│   ├── env.d.ts            # Astro client types
│   └── test/
│       ├── env.test.ts     # envField schema contract
│       ├── build.test.ts   # Build regression — dist/ has expected pages
│       ├── Navigation.test.ts
│       ├── Hero.test.ts
│       └── Footer.test.ts
├── public/                 # Static assets (favicon, og-image, badges, photos, logos)
├── astro.config.mjs        # @tailwindcss/vite plugin, envField (PUBLIC_API_URL, PUBLIC_APP_VERSION)
├── vitest.config.ts        # vitest with Astro's vite config (getViteConfig)
├── tsconfig.json           # extends astro/tsconfigs/strict
├── Dockerfile              # oven/bun:1.1 builder → nginx:alpine runtime with SSL + IMDS
├── nginx.conf              # HTTPS/443, $uri.html SSG fallback, /health endpoint, error_page 404
└── docker-entrypoint.sh    # Generates meta.json from AWS IMDSv2 at container start
```

## Commands

```bash
cd sites/landing
bun install        # Install dependencies (frozen lockfile in CI)
bun run dev        # Dev server at http://localhost:4321
bun run build      # Build static site to dist/
bun run preview    # Preview built site
bun run test       # Vitest — 16 tests across 5 files
bun run lint       # ESLint (uses root .eslintrc.cjs)
bun run format     # Prettier check (uses root .prettierrc)
bun run format:fix # Auto-format
```

## Key Conventions

- **Components:** PascalCase Astro files in `src/components/`. Each section of the landing is its own component.
- **Pages:** lowercase kebab-case in `src/pages/`. SSG route per file.
- **Layout:** Single `Layout.astro` wraps all pages. Receives `title`, optional `description`, `ogImage`. Imports `global.css` and Inter weights.
- **Styling:** Tailwind v4 utilities. Custom tokens in `@theme {}` block in `global.css` (NOT in a `tailwind.config.mjs` — that's the v3 way and it's deleted).
- **Imports:** Relative paths with `../` from current file. No path aliases configured.
- **TypeScript:** Strict mode (inherited from `astro/tsconfigs/strict`). Frontmatter uses `interface Props` when needed.

## Design Tokens (in global.css `@theme`)

| Token | Value | Usage |
|---|---|---|
| `--color-brand-dark` | `#0B1426` | Page background, scrollbar track |
| `--color-brand-surface` | `#0F172A` | Card/section backgrounds |
| Font | Inter (300–700) via `@fontsource/inter` | All text |
| Accent palette (Tailwind defaults) | Slate (borders, muted text), Emerald (selections, CTAs), Blue (decorative glows) | Throughout |
| `--animate-fade-in` | `fadeIn 0.5s ease-out forwards` | Hero entry |
| `--animate-fade-in-up` | `fadeInUp 0.8s ease-out forwards` | Section reveals |
| `--animate-slide-up` | `slideUp 0.8s ease-out forwards` | List items, cards |
| `--animate-slide-up-delayed` | `slideUp 0.8s ease-out 0.2s forwards` | Staggered reveals |
| `--animate-gradient-x` | `gradient 15s ease infinite` | Background gradient pan |

## Environment Variables

Defined in `astro.config.mjs` via `envField`:
- `PUBLIC_API_URL` (required, `optional: false`) — Lambda endpoint for contact form. CI/CD reads from SSM `/agevegacom/03-backend-serverless/00-contact-api/endpoint`.
- `PUBLIC_APP_VERSION` (optional, default `'dev'`) — Set by Docker build args from `github.ref_name` (the git tag). In `.env` for local dev.

See `.env.example` for the template (not committed: `.env` is gitignored).

## Runtime: Docker + Nginx + IMDS metadata

Two-stage Docker image:
1. **Builder** (`oven/bun:1.1`): runs `bun install --frozen-lockfile` then `bun run build`. Produces `dist/`.
2. **Runtime** (`nginx:alpine`): copies `dist/` to `/usr/share/nginx/html`. Installs `curl` + `openssl`, generates self-signed cert for localhost dev. Copies `nginx.conf` + `docker-entrypoint.sh`. EXPOSE 443.

`docker-entrypoint.sh` runs on container start:
- Tries to fetch AWS IMDSv2 token (timeout 2s).
- If on AWS: writes real region/AZ/instance-id/instance-type to `/usr/share/nginx/html/meta.json`.
- If local/non-AWS: falls back to `"Local (Simulated)"` values.
- Then exec's nginx.

The `/about-this-web` page client-fetches `/meta.json` and renders the infra info to the user (the "infra-awareness" feature).

## Deployment

```bash
# Local Docker test
docker build --build-arg PUBLIC_API_URL=https://stub.example.com --build-arg PUBLIC_APP_VERSION=test -t agevega-landing .
docker run -p 8080:443 agevega-landing
# Open https://localhost:8080 (accept self-signed cert)
```

CI/CD: tag `v*` → `00-generate-docker-image` builds `./sites/landing/` → push to ECR → trigger `01-deploy-bastion` → SSH-run `01_deploy_landing.sh` → live on `dev.agevega.com`. Then `02-deploy-production` (manual) → ASG instance refresh → `www.agevega.com`.

## Testing

- **Framework:** Vitest 4 (node environment) using `getViteConfig` from `astro/config` so vitest shares Astro's vite resolver.
- **Pattern:** Astro Container API (`experimental_AstroContainer.create()`) renders components to HTML strings; assertions run on the strings.
- **Coverage:** 16 tests across 5 files (env, build regression, Navigation, Hero, Footer). See `TESTING.md` for the strategy.
- **Run:** `PUBLIC_API_URL=stub bun run test` (envField requires PUBLIC_API_URL at runtime — provide a stub in test env).
- **CI:** `.github/workflows/03-test-sites.yml` runs vitest on PRs + push to master, matrix [landing, academy].

## Do NOT

- Add `tailwind.config.mjs` back. Tokens live in `global.css` `@theme` block (Tailwind v4 CSS-first).
- Add `@astrojs/tailwind` integration. Use `@tailwindcss/vite` in `astro.config.mjs:vite.plugins`.
- Add SSL certs to the runtime image manually; the self-signed cert is generated in the Dockerfile RUN step.
- Use SPA-style `try_files ... /index.html` in `nginx.conf` — this is SSG, use `$uri $uri/ $uri.html =404` (already configured).
- Pin `vite` to 8.x. Astro 6.1.10 internally uses vite 7.3.2; `vite` is pinned in `devDependencies` to match. Mismatched vite versions break `@tailwindcss/vite`.
- Install new dependencies without explicit approval.
