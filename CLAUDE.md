# CLAUDE.md

@~/.claude/CLAUDE.md

This file provides project-specific guidance to Claude Code when working with code in this repository.

## Project Overview

Personal portfolio website for Alejandro Vega (Senior DevSecOps Engineer & Cloud Architect) demonstrating cloud-native AWS infrastructure, Zero Trust security, and IaC best practices.

**Stack:** Astro (SSG) + TailwindCSS frontend, Docker/Nginx runtime, Lambda/API Gateway serverless backend, AWS infrastructure via Terraform, GitHub Actions CI/CD.

## Frontend Commands

```bash
cd frontend
npm install        # Install dependencies
npm run dev        # Dev server at http://localhost:4321
npm run build      # Build static site to dist/
npm run preview    # Preview built site
```

## Infrastructure (Terraform)

Modules are numbered and must be applied in order. Each sub-module is a standalone Terraform root:

```bash
cd infra/terraform/<module>/<submodule>
terraform init
terraform plan
terraform apply
```

**Module order:**

1. `00-setup/` — S3/DynamoDB remote state backend, CloudTrail, AWS Budgets
2. `01-networking/` — VPC 3-tier networking, NAT Gateway, VPC endpoints
3. `02-shared-resources/` — SSH keys, ECR repository
4. `03-backend-serverless/` — Lambda + API Gateway contact form, SES
5. `04-bastion-host/` — Dev EC2 instance behind CloudFront
6. `05-high-availability/` — Production ASG + ALB + WAF + CloudFront
7. `99-domain/` — Route53 DNS zones, ACM certificates

## Deployment Flow

```
git tag v*  →  GitHub Actions builds multi-arch Docker image (amd64 + arm64)
            →  Pushes to ECR
            →  SSH to EC2, run 01_deploy_frontend.sh (Docker + Nginx + SSL)
            →  CloudFront cache invalidation
```

Key scripts: `scripts/00_generate_cert.sh` (Let's Encrypt SSL), `scripts/01_deploy_frontend.sh` (Docker deployment).

Config values (ECR repo URL, API URL, CloudFront IDs) are fetched from **AWS SSM Parameter Store** — not hardcoded.

## Architecture

**Zero Trust security layers:** WAF → CloudFront → ALB → EC2 (each layer validates the previous).

**Two environments:**

- **Bastion/Dev** (`04-bastion-host/`): Single EC2 instance, direct CloudFront in front
- **Production** (`05-high-availability/`): ASG across multiple AZs with ALB, WAF, CloudFront

**Frontend env vars:** The `frontend/.env.example` documents `API_URL` (Lambda endpoint) and `APP_VERSION`. The Docker entrypoint injects these at container startup via `docker-entrypoint.sh`.
