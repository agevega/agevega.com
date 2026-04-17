# CLAUDE.md — agevega.com

Personal portfolio website for Alejandro Vega (Senior DevSecOps Engineer & Cloud Architect).
**Stack:** Astro 5 (SSG) + TailwindCSS 3 frontend, Docker/Nginx runtime, Lambda/API Gateway serverless backend, AWS infrastructure via Terraform, GitHub Actions CI/CD.

## Repository Structure

```
├── frontend/              # Astro SSG site
│   ├── src/
│   │   ├── components/    # 10 Astro components (PascalCase)
│   │   ├── layouts/       # Single Layout.astro
│   │   └── pages/         # Symmetric i18n: es/ (5 ES pages) + en/ (5 EN pages)
│   ├── public/            # Static assets (favicon, og-image, etc.)
│   ├── tailwind.config.mjs
│   └── astro.config.mjs
├── infra/terraform/       # AWS infrastructure (numbered modules)
├── scripts/               # Deployment & SSL scripts
├── .claude/               # Claude Code config (commands, settings)
├── .github/               # GitHub Actions workflows
└── .learning/             # Study notes & roadmaps (not deployed)
```

## Frontend Commands

```bash
cd frontend
npm install        # Install dependencies
npm run dev        # Dev server at http://localhost:4321
npm run build      # Build static site to dist/
```

## Frontend Conventions

- **Components:** One file per component in `src/components/`, always `PascalCase.astro`.
- **Pages:** Lowercase kebab-case in `src/pages/es/` and `src/pages/en/`. Both locale folders are mirrors.
- **Layout:** Single `Layout.astro` wraps all pages. Receives `title` prop. Includes Navigation + Footer.
- **Styling:** TailwindCSS utility classes. No custom CSS files except `<style is:global>` in Layout.
- **Indentation:** Tabs in config files (tailwind, astro), 2 spaces in `.astro` component markup.
- **Imports:** Relative paths with `../` from current file. No aliases configured.
- **TypeScript:** Minimal — only `Props` interface in frontmatter when needed.

## Design System

| Token | Value | Usage |
|---|---|---|
| `brand-dark` | `#0B1426` | Page background, scrollbar track |
| `brand-surface` | `#0F172A` | Card/section backgrounds |
| Font | Inter (300–700) via `@fontsource/inter` | All text |
| Accent palette | Slate (borders, muted text), Emerald (selections, CTAs), Blue (decorative glows) | Throughout |
| Animations | `fade-in`, `fade-in-up`, `slide-up`, `slide-up-delayed`, `gradient-x` | Entry animations |
| Background FX | Three `.blur-[100-120px]` divs — blue + emerald — fixed behind content | Ambient glow |

## Environment Variables

Defined in `astro.config.mjs` via `envField`:
- `PUBLIC_API_URL` (required) — Lambda endpoint for contact form
- `PUBLIC_APP_VERSION` (optional, default: `'dev'`) — Injected at Docker startup via `docker-entrypoint.sh`

See `frontend/.env.example` for reference values.

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
git tag v*  →  GitHub Actions builds multi-arch Docker image (amd64 + arm64)
            →  Pushes to ECR
            →  SSH to EC2, run 01_deploy_frontend.sh (Docker + Nginx + SSL)
            →  CloudFront cache invalidation
```

Key scripts: `scripts/00_generate_cert.sh` (Let's Encrypt SSL), `scripts/01_deploy_frontend.sh` (Docker deployment).

## Workflow Preferences

- Use **plan mode** for any change touching 3+ files or involving architectural decisions.
- **Refactors and features in separate PRs** — never mix them.
- Prefer modifying existing components over creating new ones unless explicitly asked.
- When creating a new component: follow the pattern of existing ones (frontmatter → markup → scoped style).

## Do NOT

- Install or remove npm dependencies without explicit approval.
- Reformat or rename files not directly related to the current task.
- Modify `package-lock.json` manually.
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
