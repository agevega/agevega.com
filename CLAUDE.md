# CLAUDE.md — agevega.com

Personal portfolio monorepo for Alejandro Vega (Senior DevSecOps Engineer & Cloud Architect).
**Stack:** Two static sites under `sites/` (both Astro 6), Docker/Nginx runtime, Lambda/API Gateway serverless backend, AWS infrastructure via Terraform, GitHub Actions CI/CD.

## Monorepo Layout

Each subdomain has its own self-contained app under `sites/`. Apps do not share `package.json`, lockfiles, or framework versions — only the repo-level `LICENSE` and `.gitignore`.

```
├── sites/
│   ├── landing/           # agevega.com — Astro 6 SSG, bun, Tailwind v4
│   │   ├── src/
│   │   │   ├── components/    # 10 Astro components (PascalCase)
│   │   │   ├── layouts/       # Single Layout.astro
│   │   │   └── pages/         # 5 pages: index, about, about-this-web, contact, laboratory
│   │   ├── public/            # Static assets (favicon, og-image, etc.)
│   │   ├── astro.config.mjs
│   │   ├── Dockerfile
│   │   └── nginx.conf
│   └── academy/           # academy.agevega.com — Astro 6 SSG, bun, Tailwind v4
│       ├── src/, public/, astro.config.mjs, Dockerfile, nginx.conf
│       └── (own CLAUDE.md, README.md, vitest tests)
├── infra/terraform/       # AWS infrastructure (numbered modules)
├── scripts/               # Deployment & SSL scripts (landing + academy)
├── .claude/               # Claude Code config (commands, settings)
└── .github/               # GitHub Actions workflows (landing + academy)
```

**Naming pattern:** the directory is `sites/<name>/`, the AWS ECR repo is `agevegacom-<name>`, the EC2 container is also `<name>`. Tags `v*` apply repo-wide and atomically build, test, push, and deploy BOTH sites — see `sites/CONVENTIONS.md` "Atomicity requirements" for the failure semantics (any test/build failure aborts the whole pipeline).

## Landing Commands

```bash
cd sites/landing
bun install        # Install dependencies
bun run dev        # Dev server at http://localhost:4321
bun run build      # Build static site to dist/
```

## Academy Commands

```bash
cd sites/academy
bun install        # Install dependencies
bun run dev        # Dev server at http://localhost:4322 (set in astro.config.mjs)
bun run build      # Build static site to dist/
bun run test       # Vitest schema tests
```

## Landing Conventions

- **Components:** One file per component in `src/components/`, always `PascalCase.astro`.
- **Pages:** Lowercase kebab-case in `src/pages/` (e.g., `about-this-web.astro`).
- **Layout:** Single `Layout.astro` wraps all pages. Receives `title` prop. Includes Navigation + Footer.
- **Styling:** Tailwind v4 utilities (CSS-first). Custom tokens and animations in `src/styles/global.css` `@theme {}` block.
- **Indentation:** Tabs in config files (astro), 2 spaces in `.astro` component markup.
- **Imports:** Relative paths with `../` from current file. No aliases configured.
- **TypeScript:** Minimal — only `Props` interface in frontmatter when needed.

## Design System

| Token | Value | Usage |
|---|---|---|
| `brand-dark` | `#0B1426` | Page background, scrollbar track |
| `brand-surface` | `#0F172A` | Card/section backgrounds |
| Font | Inter (300–700) via `@fontsource/inter`, exposed as `--font-sans` token | All text |
| Accent palette | Slate (borders, muted text), Emerald (selections, CTAs), Blue (decorative glows) | Throughout |
| Animations | `fade-in`, `fade-in-up`, `slide-up`, `slide-up-delayed`, `gradient-x` | Entry animations |
| Background FX | Three `.blur-[100-120px]` divs — blue + emerald — fixed behind content | Ambient glow |

## Environment Variables

Defined in `astro.config.mjs` via `envField`:
- `PUBLIC_API_URL` (required) — Lambda endpoint for contact form
- `PUBLIC_APP_VERSION` (optional, default: `'dev'`) — Injected at Docker startup via `docker-entrypoint.sh`

See `sites/landing/.env.example` for reference values.

## Infrastructure (Terraform)

Modules are numbered and must be applied in order. Each sub-module is a standalone Terraform root:

```bash
cd infra/terraform/<module>/<submodule>
terraform init && terraform plan && terraform apply
```

**Module order:**
1. `00-setup/` — S3/DynamoDB remote state backend, CloudTrail, AWS Budgets
2. `01-networking/` — VPC 3-tier (Public, Private, Data), NAT Gateway, VPC endpoints
3. `02-shared-resources/` — SSH keys, ECR repository
4. `03-backend-serverless/` — Lambda + API Gateway contact form, SES
5. `04-bastion-host/` — Dev EC2 instance behind CloudFront
6. `05-high-availability/` — Production ASG + ALB + WAF + CloudFront
7. `99-domain/` — Route53 DNS zones, ACM certificates

**Preferred AWS Region:** `eu-south-2` (Madrid).

## Architecture

**Zero Trust security layers:** WAF → CloudFront → ALB → EC2 (each layer validates the previous).

| Environment | Module | Description |
|---|---|---|
| Bastion/Dev | `04-bastion-host/` | Single EC2 instance, CloudFront in front |
| Production | `05-high-availability/` | ASG across AZs + ALB + WAF + CloudFront |

Config values (ECR repo URL, API URL, CloudFront IDs) are fetched from **AWS SSM Parameter Store** — never hardcoded.

## Deployment Flow

```
git tag v*  →  Workflow 00: test (matrix landing+academy, fail-fast) → build (matrix, multi-arch) → trigger 01
            →  Workflow 01: SSH to bastion → 00_generate_cert.sh (multi-SAN, --expand)
                          → 01_deploy_landing.sh (container `landing` on host:443)
                          → 01_deploy_academy.sh (container `academy` on host:8443)
                          → CloudFront invalidations (landing + academy, only on success)
```

Atomic semantics: any test or build failure aborts before deploy fires. CloudFront invalidations only run if both deploys succeeded. See `sites/CONVENTIONS.md` "Atomicity requirements".

Key scripts: `scripts/00_generate_cert.sh` (Let's Encrypt SSL via DNS-01, 6-SAN cert covering both sites), `scripts/01_deploy_landing.sh` and `scripts/01_deploy_academy.sh` (Docker deployment per site).

## Workflow Preferences

- Use **plan mode** for any change touching 3+ files or involving architectural decisions.
- **Refactors and features in separate PRs** — never mix them.
- Prefer modifying existing components over creating new ones unless explicitly asked.
- When creating a new component: follow the pattern of existing ones (frontmatter → markup → scoped style).

## Do NOT

- Install or remove npm dependencies without explicit approval.
- Reformat or rename files not directly related to the current task.
- Modify `bun.lock` manually.
- Touch `*.tfstate`, `*.lock`, or Terraform state files.

## Skill routing

When the user's request matches an available skill, ALWAYS invoke it using the Skill
tool as your FIRST action. Do NOT answer directly, do NOT use other tools first.
The skill has specialized workflows that produce better results than ad-hoc answers.

Key routing rules:
- Product ideas, "is this worth building", brainstorming → invoke office-hours
- Bugs, errors, "why is this broken", 500 errors → invoke investigate
- Ship, deploy, push, create PR → invoke ship
- QA, test the site, find bugs → invoke qa
- Code review, check my diff → invoke review
- Update docs after shipping → invoke document-release
- Weekly retro → invoke retro
- Design system, brand → invoke design-consultation
- Visual audit, design polish → invoke design-review
- Architecture review → invoke plan-eng-review
- Save progress, checkpoint, resume → invoke checkpoint
- Code quality, health check → invoke health
