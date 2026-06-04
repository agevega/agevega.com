# sites/ conventions

Normative rules every site under `agevega.com/sites/<name>/` must follow. Established 2026-05-02 by the cross-pollination + stack convergence audit.

**Why these conventions:** the monorepo hosts one self-contained static site per subdomain. Conventions exist so a new site can be added by copying the patterns of either landing or academy verbatim, with confidence that CI, deploy, and local dev will work.

The "MUST / SHOULD / MAY" terminology follows [RFC 2119](https://www.ietf.org/rfc/rfc2119.txt) semantics: MUST is required for the site to fit the monorepo, SHOULD is the recommended path, MAY is optional and at the site's discretion.

---

## Stack

| Concern | Convention | Required? |
|---|---|---|
| Framework | Astro 6 (SSG) | MUST |
| Astro version | Pin exact (e.g. `"6.4.4"`) until upstream rolldown+Tailwind compat lands | MUST (until Q3 2026, then re-evaluate) |
| Package manager | Bun | MUST |
| Lockfile | `bun.lock` (committed) | MUST |
| Vite | Pin exact to `7.3.2` to match Astro 6.4.4's `vite ^7.3.2` floor | MUST (transitional — see TODOS in apps for re-bump trigger) |
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
| Test workflow | `.github/workflows/03-test-sites.yml` runs `lint → check → build → test → audit` per site. Security scans live in `04-security.yml`. See "CI security gates" below | MUST |
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
| ESLint | Per-site `eslint.config.js` (ESLint 9 flat — see note below) | N/A — already per-site |
| Prettier | `sites/.prettierrc` (shared, picked up by walking up the tree) | YES — drop a `.prettierrc` inside a site dir to override |
| Prettier ignore | `sites/.prettierignore` (shared) | YES — additional `.prettierignore` per site applies cumulatively |

The repo root MUST stay free of code-style configs. Tooling configs live next to the code they format (`sites/`), not at the monorepo root.

Each site's `package.json` MUST have `lint`, `check`, `format`, `format:fix` scripts that invoke `eslint .`, `astro check`, and `prettier --check .` / `prettier --write .` from the site dir. Prettier walks up from each site dir and finds `sites/.prettierrc` automatically.

### Note: ESLint configs are inlined per-site, not shared

Each site has its own `eslint.config.js` (ESLint 9 flat config) with the full config inlined. A root-level shared config can't resolve plugins/parsers because the monorepo has no root `package.json` / `node_modules`. The flat config composes `@eslint/js`, `typescript-eslint`, and `eslint-plugin-astro`'s `flat/recommended` — the last is what parses TypeScript inside `<script>` tags (the ESLint 8 `.eslintrc.cjs` could not, so `bun run lint` was silently broken until the ESLint 9 migration).

To keep both in lockstep, edit one site's `eslint.config.js` and mirror the relevant changes to the other. The duplication is ~40 lines per site; the cost of trying to share is broken `bun run lint` on every site.

### CI security gates

`03-test-sites.yml` (PR + push to master) and the `test` job of `00-generate-docker-image.yml` (release tags) enforce, per site:

- **lint / check / build / test** — fail the job on any error.
- **`bun audit --audit-level=high`** — fails on HIGH/CRITICAL dependency advisories. Moderate/low are reported but do not block (e.g. the known `yaml` moderate via `@astrojs/check`, dev-only build tooling).

Repo-wide jobs (in `04-security.yml`, which runs on **every** PR and push to master — no path filter, so infra-only and root-only changes are scanned too):

- **gitleaks** — secret scan over full history; fails on any leak.
- **trivy** — `vuln` scan gates on HIGH/CRITICAL; `misconfig` scan (Terraform IaC + Dockerfiles) is **report-only** (`continue-on-error`), uploading SARIF to the Security tab without blocking. The current misconfig backlog (ECR tag immutability, S3/CloudTrail CMK encryption, non-root nginx, encrypted EBS, ALB invalid-header drop) is tracked for a dedicated infra-hardening PR. `node_modules`, `dist`, and `.claude` are skipped.

Image CVE scanning (`nginx:alpine` base) runs report-only in `00`'s build job after push.

---

## Site chrome canonical patterns

Established 2026-05-09 by the chrome convergence audit (`audit/optimize-design`). These rules apply to every site under `sites/` — Navigation, Footer, Layout shell. Each site replicates these patterns hand-edited per-site (no `sites/_shared/`, no component lib). Replicate, don't abstract.

### Navigation structure (canonical)

`brand mark (left) | links (centered, flex-1 justify-center) | CTA (right)` inside a container at `h-16`. The container width MUST match the site's content section width (see "Container width" below).

| Concern | Canonical | Required? |
|---|---|---|
| Container width | `max-w-7xl mx-auto px-4 sm:px-6 lg:px-8` — single canonical width across ALL sites and ALL elements (nav, footer, pages, sections). Never diverge per-site or per-element; the misalignment is visible at a glance. | MUST |
| Height | `h-16` | MUST |
| Position | `fixed top-0 z-50` | MUST |
| Backdrop | `bg-brand-dark/80 backdrop-blur-md border-b border-white/10 shadow-lg` | MUST |
| Brand mark on left | `<a href="/" aria-label>` — content per-site choice (landing: `<img>` 32×32 logo; academy: `<span>` text "AgeVega Academy"). Choose ONE; keep it minimal. | MUST |
| Centered links | `hidden md:flex flex-1 items-center justify-center` | MUST |
| CTA on right | `bg-emerald-600 text-white shadow-lg shadow-emerald-500/20`. Visible label per-site: landing "Contacto" (internal `/contact`), academy "agevega.com ↗" (external to landing) | MUST |
| Mobile menu hamburger | right-aligned via `ml-auto flex md:hidden` | MUST |

### Active state mechanism (canonical)

Server-side rendered, NOT JavaScript-driven. Use `Astro.url.pathname` in the component frontmatter. The predicate MUST handle the prefix-collision case (e.g. `/about` vs `/about-this-web`):

```ts
const pathname = Astro.url.pathname;

const isActive = (path: string): boolean => {
  if (path === '/') return pathname === '/';
  return pathname === path || pathname.startsWith(path + '/');
};
```

The naive `pathname.startsWith(path)` is **forbidden** — it matches `/about` when on `/about-this-web`. The corrected predicate above is required (regression-tested in each site's `Navigation.test.ts`).

### Active visual (canonical)

Active link: `text-emerald-400 font-semibold`, **no background**.
Inactive link: `text-slate-300 hover:text-white hover:bg-white/5`.
Active link MUST also receive `aria-current="page"` for screen reader semantics.

The CTA Contacto is the only element with a solid emerald fill. The active link is text-only emerald to keep visual hierarchy: "you are here" (text) vs "click to act" (filled CTA).

### CTA Contacto (canonical)

Same visual styling across all sites: `bg-emerald-600 text-white shadow-lg shadow-emerald-500/20 hover:bg-emerald-500`.

| Site | href | Visible label | Behavior |
|---|---|---|---|
| landing | `/contact` | `Contacto` | internal route |
| academy | `https://agevega.com/contact` | `agevega.com` | external — MUST have `target="_blank" rel="noopener noreferrer"` AND `aria-label="agevega.com (se abre en nueva pestaña)"`. NO visible `↗` glyph in the nav CTA (the domain name itself signals destination; the glyph adds visual noise to the pill) |
| (future site) | external if no own form, internal otherwise | per-site, see rule below | follow rule above |

If a site does not have its own `/contact` route, link to landing's contact page. Do NOT duplicate the contact form per-site. The visible label SHOULD reflect the destination domain (e.g. `agevega.com ↗`) rather than the abstract action ("Contacto"), so the user knows they are leaving the current subdomain. The pattern decision: the visitor leaves the subdomain context but lands on the same brand surface (agevega.com).

### Scroll-aware navbar (canonical)

Both sites condense the navbar at `scrollY > 20px` (toggle `py-2`). Implementation MUST:
- import `shouldCondense` from `src/lib/scroll-condense.ts` (per-site copy of the same 3-line module)
- use `requestAnimationFrame` guard to coalesce events (avoid 60Hz layout reads)
- attach with `{ passive: true }`

```ts
import { shouldCondense } from '../lib/scroll-condense';

let ticking = false;
window.addEventListener('scroll', () => {
  if (!ticking) {
    requestAnimationFrame(() => {
      navbar.classList.toggle('py-2', shouldCondense(window.scrollY));
      ticking = false;
    });
    ticking = true;
  }
}, { passive: true });
```

### Mobile menu (canonical)

- Toggle via `aria-expanded` on the hamburger button
- Focus trap on Tab/Shift+Tab while open
- Escape closes the menu and returns focus to the hamburger
- Click on any link inside closes the menu

Implementation lives inline in `Navigation.astro`'s `<script>` block. Replicate verbatim across sites — when fixing a bug in one, fix it in all.

### Layout shell (canonical)

| Concern | Canonical | Required? |
|---|---|---|
| Skip-to-content link | first focusable element, `href="#main-content"` | MUST |
| `<main>` element | MUST have `id="main-content"` for the skip link target | MUST |
| `<main>` top padding | NO `pt-16` on `<main>` — the home hero MUST be `min-h-screen flex items-center` to absorb the nav overlap with vertical centering. Non-home pages MUST start their outer container with `pt-24` minimum (96px = 64px nav + 32px breathing room); `py-12` alone is INSUFFICIENT and the nav will clip the page heading. 404 pages with `py-32` are fine. | MUST |
| Ambient glow | three fixed `blur-[100-120px]` divs (blue/emerald/blue) inside `<div class="fixed inset-0 z-[-1] pointer-events-none">`, sized as percentages of viewport (no `overflow-hidden` wrapper). Replicate landing's markup verbatim. | MUST |
| Body class | `bg-brand-dark text-slate-100 font-sans antialiased selection:bg-emerald-500/30 overflow-x-hidden relative flex flex-col min-h-screen` — identical across sites so backgrounds and selection color match | MUST |
| Custom scrollbar | `<style is:global>` block with `::-webkit-scrollbar` rules using `#0b1426` track and `#1e293b` thumb, plus `html { overflow-y: scroll }` to prevent layout shift. Replicate verbatim | MUST |
| Reduced-motion media query | inside the same `<style is:global>` block, neutralizes animations / transitions / scroll-smoothing | MUST |
| Version tag (home only) | placed inside the home hero `<section>` at `absolute bottom-4 right-4 z-20`, hero MUST be `min-h-screen` so the tag visually anchors to the bottom-right of the first viewport | MUST |
| OG meta | `og:type, og:url, og:title, og:description, og:image` (image optional) | MUST |
| Twitter card meta | `twitter:card=summary_large_image, twitter:url, twitter:title, twitter:description, twitter:image` | SHOULD |
| Canonical URL | `<link rel="canonical">` from `Astro.url.pathname + Astro.site` | MUST |
| Title pattern | per-site choice (landing uses `{title}` directly, academy uses `{title} | AgeVega Academy`) | MAY |
| `lang` attribute | `lang="es"` (project default) | MUST |

### Footer

Footers diverge by site density — there is **no** unified canonical footer. The cross-cutting rules:

| Concern | Canonical | Required? |
|---|---|---|
| Container width | `max-w-7xl mx-auto px-4 sm:px-6 lg:px-8` (same canonical as nav, same across sites) | MUST |
| Right-side group wrapper | links on the right side MUST be wrapped in `<div class="flex items-center gap-6">` (even if there is only one link) — keeps the structural shape identical across sites | MUST |
| Licence attribution | factual against repo `LICENSE` (currently MIT) — never "Todos los derechos reservados" | MUST |
| Cross-site link | every site SHOULD include a link to the sibling site as the last footer element, with `target="_blank" rel="noopener noreferrer"` and the `↗` glyph | SHOULD |
| Link set | per-site, appropriate to content density. Landing: minimal (copyright + cross-site). Academy: rich (copyright + Cursos + RSS + cross-site). | MAY |
| Border / spacing | `border-t border-slate-800/60 py-8` | SHOULD |

The decision (audit 2026-05-09): replicating the same link set on both sites was ruled noisy. Each footer matches its site's content nature.

### `global.css` tokens (canonical)

Every site's `src/styles/global.css` MUST declare these `@theme` tokens:

```css
--color-brand-dark: #0b1426;
--color-brand-surface: #0f172a;
--animate-fade-in: fadeIn 0.5s ease-out forwards;
--animate-fade-in-up: fadeInUp 0.8s ease-out forwards;
--animate-slide-up: slideUp 0.8s ease-out forwards;
--animate-slide-up-delayed: slideUp 0.8s ease-out 0.2s forwards;
```

Hex casing: lowercase (`#0b1426`, not `#0B1426`).
Animations a site does not use SHOULD be omitted (e.g. landing previously declared `--animate-gradient-x` without using it — deleted in this audit).

`.content-body` markdown styles live in `global.css` only on sites that use Astro content collections (today: academy only). Other sites MUST NOT define `.content-body`.

### Version tag env (canonical)

Every site's `astro.config.mjs` MUST declare `PUBLIC_APP_VERSION` with `default: 'Localhost'` (NOT `'dev'`). The version tag in the home hero displays this value when no `.env` overrides it. Using "Localhost" as the dev-time default makes the tag legible to humans during local work; CI/CD overrides with the real `vX.Y.Z` git tag at build time.

### Tests (canonical)

Each site MUST have, at minimum:
- `src/test/Navigation.test.ts` with route-collision regression test (asserts `/about` does NOT match `/about-this-web` and vice versa)
- `src/test/Footer.test.ts` asserting the site's chosen container width (must match nav) and licence-text
- `src/test/scroll-condense.test.ts` for the pure threshold function (the DOM integration of the scroll listener is not unit-tested in vitest's node env; document the gap)
- `vitest.config.ts` MUST use `getViteConfig` from `astro/config` to enable Container API

Adding a new site: copy the chrome from either landing or academy (post 2026-05-09 they comply with this section). Diverge only if the site's IA genuinely needs different chrome — and update this section.

### Future: deduplication

While `replicate, don't abstract` holds with N=2 sites, hand-replication of identical chrome compounds. If a third site lands and its chrome is also identical, this section's rules SHOULD be promoted to a `sites/_chrome/` directory containing two verbatim files (`Navigation.astro`, `Footer.astro`) imported by each site's `Layout.astro`. That is *deduplication*, not parametrization — the user-stated preference still holds. Tracked in `TODOS.md`.

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
bun add astro@6.4.4
bun add -d @astrojs/check typescript @types/node \
  @fontsource/inter @tailwindcss/vite tailwindcss vite@7.3.2 vitest

# Prettier config shared at sites/.prettierrc (auto-picked-up via tree-walk).
# ESLint must be configured per-site (parser/plugin resolution requires it):
# copy sites/landing/eslint.config.js into the new site dir verbatim.
bun add -d @eslint/js eslint@^9 typescript-eslint globals \
  astro-eslint-parser eslint-plugin-astro \
  prettier prettier-plugin-astro

# Build & test
bun install
bun run build
bun run test

# Update sites/CONVENTIONS.md "Local dev" table with the new site's port
# Add a TODO in academy/landing CHANGELOG noting the new sibling site exists
```

If your new site needs a CI deploy pipeline, extend the existing matrix in `.github/workflows/00-generate-docker-image.yml` and `03-test-sites.yml` to include the new site, then add deploy steps in `01-deploy-bastion.yml` and `02-deploy-production.yml` following the landing/academy parallel pattern. Update tag namespacing per the rules above.
