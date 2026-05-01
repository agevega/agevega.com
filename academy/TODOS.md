# Academy — Deferred TODOs

Items explicitly deferred from v1. Each has a trigger — don't work on these until the trigger is met.

---

## TODO: Pagefind full-text search (P2)

**Trigger:** `getCollection('courses')` returns 10+ entries  
**What:** `pagefind` CLI post-build script + `SearchWidget.astro` component in `/cursos`  
**Integration:**
```bash
bun run build && bunx pagefind --source dist/
```
Then add `SearchWidget.astro` to `cursos/index.astro` that loads the Pagefind UI.  
**Effort:** M (2-3h)  
**Blocked by:** catalog size — search has no value with 3-5 courses

---

## TODO: CONTRIBUTING.md + course template (P3)

**Trigger:** first external contributor appears, or first GitHub issue asking "how do I contribute?"  
**What:**
- `CONTRIBUTING.md` — step-by-step guide: fork, copy template, fill frontmatter, open PR
- `src/content/courses/_template.md` — frontmatter scaffold with inline comments explaining each field  
**Effort:** S (30 min)  
**Not blocking:** community hasn't emerged yet in v1

---

## TODO: Plausible.io analytics (P2)

**Trigger:** `academy.agevega.com` DNS is active (Plausible counts by domain — localhost generates noise)  
**What:** Add one script tag to `src/layouts/Layout.astro` `<head>`:
```html
<script defer data-domain="academy.agevega.com"
  src="https://plausible.io/js/plausible.js"></script>
```
**Effort:** S (15 min)  
**Why it matters:** Plausible shows which categories drive RSS subscriptions — the core flywheel metric

---

## TODO: Link from agevega.com navigation to Academy (P2)

**Trigger:** Academy is deployed at `academy.agevega.com`  
**What:** Add "Academy" link to `agevega.com/frontend/src/components/Navigation.astro`  
**Effort:** S (10 min)  

---

## TODO: Tag cloud / tag filter on /cursos (P3)

**Trigger:** multiple courses share tags and users express interest in tag-based browsing  
**What:** Extend `FilterBar.astro` to support tag filtering in addition to category filtering  
**Note:** The `tags` field already exists in the Zod schema — no schema changes needed  
**Effort:** M (1-2h)

---

## TODO: Difficulty color-coding on CourseCard (P3)

**Trigger:** polish phase after v1 ships  
**What:** Add colored badge on card: green = beginner, yellow = intermediate, red = advanced  
**Effort:** S (30 min)

---

## TODO: GitHub Actions CI/CD (Phase 2)

**Trigger:** ready to deploy to AWS  
**What:** `.github/workflows/deploy.yml` — build Docker image → push to ECR → deploy on AWS EC2 (same pattern as agevega.com)  
**Effort:** M (2-3h)  
**Depends on:** AWS infra (ECR repo, EC2 instance or ECS) provisioned via Terraform
