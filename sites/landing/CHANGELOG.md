# Changelog — landing

## v1.1.0 — 2026-05-02 — sites/ parity audit + stack convergence

### Build pipeline
- Migrated build stack from npm + Astro 5 + Tailwind 3 → bun + Astro 6 + Tailwind v4 (CSS-first).
- Replaced `tailwind.config.mjs` with `src/styles/global.css` `@theme {}` block + `@keyframes` blocks (5 animations: `fade-in`, `fade-in-up`, `slide-up`, `slide-up-delayed`, `gradient-x`).
- Replaced `@astrojs/tailwind` integration with `@tailwindcss/vite` plugin in `astro.config.mjs`.
- Replaced `package-lock.json` with `bun.lock`. Pinned `vite@7.3.2` to match Astro 6.1.10's internal vite (avoids `@tailwindcss/vite` + rolldown incompatibility on vite 8).
- Migrated `Dockerfile` build stage from `node:lts-alpine` + `npm install` → `oven/bun:1.1` + `bun install --frozen-lockfile`. Runtime stage (nginx:alpine, SSL self-signed, IMDS entrypoint, EXPOSE 443) preserved.
- Aligned `tsconfig.json` to `astro/tsconfigs/strict`.

### Tests (new)
- Added Vitest 4 + 16 tests across 5 files: `env`, `build` (regression), `Navigation`, `Hero`, `Footer`.
- Tests use Astro Container API (stable since Astro 6) for component render-and-assert.

### Docs (new)
- Added `CLAUDE.md` (Claude Code project instructions).
- Added `TESTING.md` (test strategy + patterns).
- Added `CHANGELOG.md` (this file).
- Added `TODOS.md` (deferred work).

### Pages
- Added `src/pages/404.astro` — custom 404 page (was missing; nginx fell through to home with 200 status before).

### Runtime
- Fixed `nginx.conf` SSG-style `try_files`: `$uri $uri/ $uri.html =404` (was SPA-style `/index.html` fallback). Added `error_page 404 /404.html;`.

### Tooling
- Added shared Prettier configs `.prettierrc` + `.prettierignore` at `sites/`. Each site uses them via tree-walk in the `format` scripts. ESLint configs are inlined per-site (`.eslintrc.cjs` in each site dir).

### Reference
Driven by audit design doc: `~/.gstack/projects/agevega-agevega.com/agevega-master-design-20260501-171908-sites-audit-parity.md`. Eng-reviewed via `/gstack-plan-eng-review` 2026-05-01.

---

## v1.0.0 — 2026-05-01 — sites/ restructure (rename frontend → landing)

- Moved `frontend/` to `sites/landing/` as part of the monorepo restructure (multi-app under `sites/`).
- Renamed AWS resources end-to-end: ECR `agevegacom-frontend` → `agevegacom-landing`, EC2 container `frontend` → `landing`, deploy script `01_deploy_frontend.sh` → `01_deploy_landing.sh`.
- Production deploy verified at `https://www.agevega.com/`.

## Earlier history (pre-v1.0.0)

Tracked in git log under the original `frontend/` path. Tags from v0.1.0 to v0.29.0 cover the iterative development of the portfolio site. After the restructure, version numbering continues from v1.0.0.
