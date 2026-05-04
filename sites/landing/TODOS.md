# TODOS — landing

Deferred work for landing. Each entry: trigger condition + what + why + effort estimate.

---

## TODO: Re-enable Astro 6.2.x + vite 8 once `@tailwindcss/vite` ships rolldown compat (P3)

**Trigger:** `@tailwindcss/vite` releases a version that supports rolldown's `BindingViteResolvePluginConfig` (vite 8 with rolldown bundler).
**What:** Bump `astro` from `6.1.10` (pinned exact) → `^6.2.x`. Remove the `vite: "7.3.2"` pin in `devDependencies`. Re-run `bun install` and verify `bun run build` passes.
**Why:** Vite 8 with rolldown is meaningfully faster (~2-3x) for cold builds. Today we pin vite 7.3.2 to avoid a tooling incompatibility, not because vite 8 is wrong.
**Effort:** S (~15 min CC). Depends on upstream fix in `@tailwindcss/vite` ecosystem.
**Refs:** Audit eng-review issue 1A; bun.lock comparison 2026-05-02.

---

## TODO: Migrate ESLint to flat config (eslint.config.js) (P3)

**Trigger:** ESLint v8 reaches end-of-life or a plugin we depend on drops v8 support.
**What:** Replace each site's `.eslintrc.cjs` with `eslint.config.js` (flat config). Bump `eslint` to v9, `@typescript-eslint/*` to v8. Update `lint` scripts if needed.
**Why:** Flat config is the future of ESLint. v8 + .eslintrc is on a deprecation track.
**Effort:** S (~30 min CC). Currently boring-by-default — wait for actual deprecation pressure.

---

## TODO: Lighthouse / Core Web Vitals baseline (P2)

**Trigger:** Anyone wonders "is this site fast?".
**What:** Run `/gstack-benchmark` against `https://www.agevega.com/` and `http://localhost:4321/`. Capture LCP, CLS, FID, TBT for each route. Save baseline. Compare to academy.
**Why:** Tailwind v4 should reduce bundle size ~20%. We have no measurement to confirm.
**Effort:** M (~45 min CC + analysis).

---

## TODO: Audit landing's CSP and security headers (P2)

**Trigger:** Anyone wonders "what's our XSS surface?".
**What:** Run `/gstack-cso` against landing. Add `add_header Content-Security-Policy ...` to `nginx.conf` if appropriate. Address findings.
**Why:** Currently `nginx.conf` has only basic SSL hardening; no CSP, no HSTS preload, no Referrer-Policy.
**Effort:** M (~1 h CC + iteration).

---

## TODO: 01_deploy_landing.sh add `set -euo pipefail` (P1, but separate PR)

**Trigger:** Already known — see project memory `agevega.com CI green doesn't mean deployed`.
**What:** Add `set -euo pipefail` at the top of `scripts/01_deploy_landing.sh` so CI fails red when `docker run` fails (currently the script's exit code is from `docker image prune`, which always succeeds, making CI green-lie).
**Why:** Last bastion deploy silently failed (port 443 conflict from legacy container) but CI reported success. Cost an hour of debugging. Won't happen again with `set -e`.
**Effort:** XS (1-line change). Cleanup PR, NOT this audit.
**Status:** Documented. Cleanup PR pending.

---

## Maintenance ideas (no trigger yet)

- Animation respect for `prefers-reduced-motion` is in `Layout.astro:117-126` (CSS reset). Verify it actually disables the @theme animations after Tailwind v4 migration.
- Consider sitemap integration (`@astrojs/sitemap`) for landing — academy has it. Low value for a 5-page portfolio but standard practice.
- Consider RSS feed if landing ever publishes blog posts.
