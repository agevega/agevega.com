# sites/ conventions

Normative rules every site under `agevega.com/sites/<name>/` must follow. Established 2026-05-02 by the cross-pollination + stack convergence audit.

**Why these conventions:** the monorepo hosts one self-contained static site per subdomain. Conventions exist so a new site can be added by copying the patterns of either landing or academy verbatim, with confidence that CI, deploy, and local dev will work.

The "MUST / SHOULD / MAY" terminology follows [RFC 2119](https://www.ietf.org/rfc/rfc2119.txt) semantics: MUST is required for the site to fit the monorepo, SHOULD is the recommended path, MAY is optional and at the site's discretion.

---

## Stack

| Concern | Convention | Required? |
|---|---|---|
| Framework | Astro 6 (SSG) | MUST |
| Astro version | Pin exact (e.g. `"6.1.10"`) until upstream rolldown+Tailwind compat lands | MUST (until Q3 2026, then re-evaluate) |
| Package manager | Bun | MUST |
| Lockfile | `bun.lock` (committed) | MUST |
| Vite | Pin to `7.3.2` to match Astro 6.1.10's internal vite | MUST (transitional — see TODOS in apps for re-bump trigger) |
| Tailwind | v4 CSS-first (`@import 'tailwindcss'` + `@theme {}` block) | MUST |
| Tailwind plugin | `@tailwindcss/vite` in `astro.config.mjs:vite.plugins` | MUST |
| TypeScript | `extends: "astro/tsconfigs/strict"` in `tsconfig.json` | MUST |
| Fonts | `@fontsource/inter` weights 300–700 | SHOULD (consistency across sites) |
| Sitemap | `@astrojs/sitemap` integration | MAY |
| RSS | `@astrojs/rss` if site has feed-like content | MAY |
| Content collections | Zod schema in `src/content.config.ts` | MAY (depends on content model) |

### Rationale: why Bun + Astro 6 + Tailwind v4

- Bun's install is ~10× faster than npm; CI savings compound across many builds.
- Astro 6 brings stable Container API (used in component tests) + better content collection types.
- Tailwind v4 CSS-first removes the JS config file and generates only used utilities (smaller bundle).
- Pinning Vite to 7.3.2 (transitional): vite 8 + rolldown breaks `@tailwindcss/vite` resolveOptions today. When upstream resolves, both apps re-bump together (boring choice).

---

## Container

| Concern | Convention | Required? |
|---|---|---|
| Builder image | `oven/bun:1.1` for SSG build stage | MUST |
| Runtime image | `nginx:alpine` for serving static dist | MUST |
| Two-stage build | `COPY --from=builder /app/dist /usr/share/nginx/html` | MUST |
| `.dockerignore` | Exclude `node_modules`, `dist`, `.git`, `.env`, `.astro`, `.vscode`, `*.md`, `Dockerfile` | MUST |
| HTTPS in container | Self-signed cert via `openssl req` in Dockerfile, EXPOSE 443 | SHOULD (CloudFront terminates real TLS upstream) |
| Health endpoint | `nginx.conf` `location /health { return 200 'OK'; }` | SHOULD (ALB depends on it) |
| IMDS metadata entrypoint | `docker-entrypoint.sh` reading IMDSv2 → `/usr/share/nginx/html/meta.json` | MAY (only if site renders infra info to user) |
| Static asset cache | `nginx.conf` `expires 1y; add_header Cache-Control "public, max-age=31536000, immutable"` for `*.{js,css,png,jpg,...}` | SHOULD |

### nginx try_files: SSG, NOT SPA

```nginx
location / {
    try_files $uri $uri/ $uri.html =404;
}
error_page 404 /404.html;
```

**MUST** use `=404` fallback (not `/index.html`). Astro produces `<route>/index.html` for each route; `$uri.html` handles clean URLs without trailing slashes; `=404` returns proper HTTP 404 status for missing pages (not silent 200 with home content).

If your site has a custom 404 design, add `src/pages/404.astro` (Astro builds it to `dist/404.html`) and the `error_page 404 /404.html;` directive serves it.

---

## Tests

| Concern | Convention | Required? |
|---|---|---|
| Test runner | Vitest 4 | MUST |
| Vitest config | `vitest.config.ts` using `getViteConfig` from `astro/config` | MUST |
| Test environment | `node` (Astro components are SSR; no DOM needed) | MUST |
| Test directory | `src/test/**/*.test.ts` | MUST |
| `bun run test` script | `vitest run` | MUST |
| Component testing | Astro Container API (`experimental_AstroContainer`) | SHOULD |
| Build regression test | `src/test/build.test.ts` asserting expected `dist/<route>.html` files | SHOULD |
| Schema test (if content collections) | `src/test/schema.test.ts` mirroring Zod schema inline | SHOULD (if `content.config.ts` exists) |
| Coverage goal | 100% of intentional branches via boring tests; not test-LOC chasing | SHOULD |

### Why `getViteConfig`

Without it, vitest can't resolve `*.astro` imports because vitest doesn't know the Astro compiler exists. `getViteConfig(defineConfig({...}))` injects Astro's vite plugins into vitest's resolver.

---

## Documentation

Every site MUST have at the root of its directory:

| File | Content | Audience |
|---|---|---|
| `README.md` | Stack, dev commands, Docker run, link to root README | Humans onboarding |
| `CLAUDE.md` | Monorepo context, repo structure, commands, conventions, design tokens, env vars, runtime, deploy, testing, do-NOT list | AI agents (Claude Code) |
| `TESTING.md` | Test framework, run command, what's covered, patterns, do-NOT list | Anyone adding tests |
| `CHANGELOG.md` | Date-versioned change history, latest at top | Anyone tracking deltas |
| `TODOS.md` | Deferred work with trigger condition, what, why, effort estimate | Future-self / contributors |

The doc files do NOT have to be exhaustive — empty-but-present is better than missing. CHANGELOG can have one entry. TODOS can say "no pending TODOs". The minimum is: anyone walking into the site can find the basics.

---

## Local dev

| Site | Dev port | How set |
|---|---|---|
| landing | 4321 | Astro default (no override) |
| academy | 4322 | `server: { port: 4322, host: true }` in `astro.config.mjs` |
| (future site #3) | 4323 | Same pattern, increment by 1 |

`host: true` in academy lets the dev server bind to `0.0.0.0` for Windows-side access from WSL2 (`http://172.20.x.x:4322/`). MAY apply to other sites if needed.

Both apps can run in parallel: open two terminals, `bun run dev` in each. No port collision, no resource contention beyond CPU.

---

## CI/CD

| Concern | Convention | Required? |
|---|---|---|
| Tag convention | `v*` (repo-wide, e.g. `v1.1.0`) — every tag deploys ALL sites | MUST |
| Test workflow | `.github/workflows/03-test-sites.yml` runs `bun install --frozen-lockfile && bun run build && bun run test` per site | MUST (gates merges informationally; not blocking by default) |
| Build workflow | Per site, e.g. `00-generate-docker-image.yml` for landing → push to ECR | MUST (per site that deploys to prod) |
| ECR repo naming | `agevegacom-<site>` (e.g. `agevegacom-landing`) | SHOULD |
| Container name on EC2 | `<site>` (e.g. `landing`) | SHOULD |
| Deploy script | `scripts/01_deploy_<site>.sh` with `set -euo pipefail` at top | MUST (script must propagate failures; CI green-lying is a known footgun if `set -e` missing) |
| Deploy script SSH verification | After workflow reports success, MUST ssh to bastion + `docker ps` + `curl -k` to verify before tagging prod | MUST (workflow status is necessary but not sufficient) |
| Production deploy trigger | Manual `workflow_dispatch` only (NOT auto on tag push) | MUST |

### Deploy strategy: deploy all sites, every tag

A `v*` tag re-deploys every site, regardless of whether that site changed. This is a deliberate choice for resilience — never namespace tags as `landing-v*` / `academy-v*`. The repo always uses a single `v*` convention.

Why deploy-all-every-time:

- **Every tag is a known-good cut of the entire repo.** No ambiguity about "what version is academy on right now" when production is debugging.
- **Idempotent redeploys are cheap.** A site with no source changes builds the same Docker layers (cache hit), pushes the same ECR digest (no-op), and the deploy script's `docker pull` returns the same image. The runtime container restarts but serves the same bytes.
- **Continuous-deployment hygiene.** Every tag exercises the full deploy path for every site, so the path stays warm and tested. A site that hasn't deployed in 3 months is a deploy that's about to break.

The cost of a no-op redeploy (a few seconds of CI + an idempotent container restart) is much smaller than the cost of an infrequent-firing deploy path silently rotting until the day you actually need it.

### Atomicity requirements for the multi-site pipeline

Every `v*` tag deploys all sites as one atomic unit. The pipeline gates each phase on every site succeeding:

- **Test gate.** Workflow `00-generate-docker-image.yml` has a `test` job (matrix `[landing, academy]`, `fail-fast: true`). Any test failure aborts before any image is built.
- **Build gate.** Same workflow's `build` job (`needs: test`, same matrix, `fail-fast: true`). Both pushes must succeed for the deploy trigger to fire. Tag glob is `v*` — identical across all sites.
- **Deploy gate.** Workflow `01-deploy-bastion.yml` runs sequential steps in a single job: the academy deploy step does not start until the landing deploy step succeeds. GitHub Actions' default `if: success()` provides this for free. CloudFront invalidations only run when both deploys succeeded.
- **Concurrency is repo-wide:** `concurrency: deploy-${{ github.ref }}`. NOT per-site. A second tag pushed mid-deploy waits.

Trade-off explicitly accepted: a flaky test or build on one site blocks the release of the other. For a personal portfolio without an SLA, atomic consistency beats per-site availability. Revisit if the trade-off ever costs real customer impact.

---

## Code style

| Tool | Config location | Per-app override? |
|---|---|---|
| ESLint | Per-site `.eslintrc.cjs` (inlined — see note below) | N/A — already per-site |
| Prettier | `sites/.prettierrc` (shared, picked up by walking up the tree) | YES — drop a `.prettierrc` inside a site dir to override |
| Prettier ignore | `sites/.prettierignore` (shared) | YES — additional `.prettierignore` per site applies cumulatively |

The repo root MUST stay free of code-style configs. Tooling configs live next to the code they format (`sites/`), not at the monorepo root.

Each site's `package.json` MUST have `lint`, `format`, `format:fix` scripts that invoke `eslint .` and `prettier --check .` / `prettier --write .` from the site dir. Prettier walks up from each site dir and finds `sites/.prettierrc` automatically.

### Note: ESLint configs are inlined per-site, not shared

ESLint v8 resolves parsers and plugins from the location of the config file, not the working directory. The monorepo has no root `package.json` and no root `node_modules`, so a root-level shared ESLint config can't resolve `@typescript-eslint/parser` or `astro-eslint-parser`. Instead, each site has its own `.eslintrc.cjs` with the full config inlined.

To keep both in lockstep, edit one site's `.eslintrc.cjs` and mirror the relevant changes to the other. The duplication is ~50 lines per site; the cost of trying to share is broken `bun run lint` on every site.

Future state: ESLint flat config (`eslint.config.js`) uses ESM imports and has different resolution rules; that may unlock a shared config. Tracked per-site in `TODOS.md`.

---

## What sites MUST NOT do

- **No root-level `package.json`.** Each site has its own. There is no monorepo orchestration tool (no nx, no turborepo, no lerna). The parent dir `sites/` is for grouping only.
- **No shared lockfile across sites.** Each `bun.lock` is independent.
- **No symlinks across sites.** If two sites need the same code, copy it (or extract to a separately-versioned package and depend on it explicitly via npm/bun resolution).
- **No coupling at runtime.** Sites do not import from each other at build time.
- **No tailwind.config.mjs.** Tailwind v4 is CSS-first; tokens live in the `@theme {}` block in `src/styles/global.css`.
- **No `@astrojs/tailwind` integration.** Use `@tailwindcss/vite` plugin in `astro.config.mjs:vite.plugins`.
- **No `try_files $uri $uri/ /index.html` in nginx.** That's SPA fallback; this is SSG. Use `$uri.html =404`.

---

## Adding a new site

```bash
cd agevega.com/sites/
mkdir my-new-site && cd my-new-site

# Copy starter from landing (richest current template):
cp ../landing/{Dockerfile,nginx.conf,astro.config.mjs,tsconfig.json,vitest.config.ts,.dockerignore,.env.example} .
cp -r ../landing/src/styles ./src/styles
# Edit each file to adapt: package.json name, astro.config site URL,
# Dockerfile any specific runtime needs, nginx server_name, etc.

# Pick a port:
# Edit astro.config.mjs to add `server: { port: 4323, host: true }`

# Bootstrap deps:
bun init -y    # creates package.json — replace contents with the convention above
bun add astro@6.1.10
bun add -d @fontsource/inter @tailwindcss/vite tailwindcss vite@7.3.2 vitest

# Prettier config shared at sites/.prettierrc (auto-picked-up via tree-walk).
# ESLint must be configured per-site (parser/plugin resolution requires it):
# copy sites/landing/.eslintrc.cjs into the new site dir verbatim.
bun add -d @typescript-eslint/eslint-plugin@^7 @typescript-eslint/parser@^7 \
  astro-eslint-parser eslint@^8 eslint-plugin-astro \
  prettier prettier-plugin-astro

# Build & test
bun install
bun run build
bun run test

# Update sites/CONVENTIONS.md "Local dev" table with the new site's port
# Add a TODO in academy/landing CHANGELOG noting the new sibling site exists
```

If your new site needs a CI deploy pipeline, follow the academy CI/CD pattern (deferred until first cut) or copy from landing's three workflow files. Update tag namespacing per the rules above.
