# CLAUDE.md — academy

AgeVega Academy: static course site for DevSecOps and Cloud content from the AgeVega Master YouTube channel.
**Stack:** Astro 6 (SSG) + Tailwind v4 (CSS-first, no config file) + Bun, Docker/Nginx runtime.

## Monorepo context

This app lives at `agevega.com/academy/`, sibling of `agevega.com/frontend/`. The monorepo at `agevega.com/` hosts multiple webapps, one per subdomain. Conventions:

- **Sibling-app pattern.** Each subdomain gets its own top-level directory at the repo root (`agevega.com/academy/`, `agevega.com/frontend/`, future apps follow the same pattern).
- **Self-contained.** Each app has its own `Dockerfile`, `nginx.conf`, package manager, and framework version. No shared `package.json`, no monorepo orchestration tool. The frontend uses npm + Astro 5; this app uses bun + Astro 6. They do not interact at build time.
- **No root-level package manifests.** Do NOT look for `package.json` at the monorepo root. Each app's manifest lives in its own directory.
- **Shared by inheritance only:** the repo-level `.gitignore` (with wildcards `*/node_modules/`, `*/.astro/`) and the repo-level `LICENSE` cover this app. Do not introduce a per-app `LICENSE` unless licenses diverge.
- **CI/CD scope.** The 3 workflows in `agevega.com/.github/workflows/` (00-generate-docker-image, 01-deploy-bastion, 02-deploy-production) belong to the `frontend` app. Academy's CI/CD is deferred to a follow-up iteration.

## Repository Structure

```
frontend/
├── src/
│   ├── components/        # Astro components (PascalCase)
│   │   ├── CourseCard.astro
│   │   ├── FilterBar.astro
│   │   ├── Footer.astro
│   │   ├── HeroSection.astro
│   │   ├── Navigation.astro
│   │   ├── ResourceList.astro
│   │   └── VideoEmbed.astro
│   ├── content.config.ts  # Zod schema for courses collection (Astro content config)
│   ├── content/
│   │   └── courses/       # Markdown course files
│   ├── layouts/
│   │   └── Layout.astro   # Base layout with SEO, ambient glow, nav/footer
│   ├── pages/
│   │   ├── index.astro    # Home: hero + featured courses
│   │   ├── cursos/
│   │   │   ├── index.astro    # All courses + FilterBar
│   │   │   └── [slug].astro   # Individual course page
│   │   ├── 404.astro
│   │   └── rss.xml.js
│   └── styles/
│       └── global.css     # Tailwind v4 @import + .content-body markdown styles
├── public/                # Static assets (favicon, og-image)
├── astro.config.mjs       # Tailwind vite plugin, sitemap, Shiki github-dark
├── Dockerfile             # oven/bun:1.1 builder → nginx:alpine
└── nginx.conf             # Plain HTTP/80, try_files for SSG, 1y asset cache
```

## Commands

```bash
cd frontend
bun install        # Install dependencies
bun run dev        # Dev server at http://localhost:4321
bun run build      # Build static site to dist/
bun run preview    # Preview built site
```

## Key Conventions

- **Slugs:** always `entry.id.replace(/\.mdx?$/, '')` — never `entry.slug` (deprecated in Astro 5+)
- **Content render:** `import { render } from 'astro:content'; const { Content } = await render(entry)` (Astro 5+ API)
- **Tailwind:** CSS-first v4. All tokens in `@theme {}` block in global.css. No `tailwind.config.mjs`.
- **Markdown styles:** `.content-body` class in global.css (no @tailwindcss/typography dependency)
- **YouTube thumbnails:** `mqdefault.jpg` (320×180) for cards, `hqdefault.jpg` (480×360) for og:image
- **Video embeds:** `youtube-nocookie.com` domain, `loading="lazy"`
- **External links:** always `target="_blank" rel="noopener noreferrer"`

## Design Tokens

| Token | Value | Usage |
|---|---|---|
| `brand-dark` | `#0B1426` | Page background |
| `brand-surface` | `#0F172A` | Card backgrounds |
| Accent | Emerald-500 | CTAs, active states, hover borders |
| Font | Inter (300–700) via `@fontsource/inter` | All text |
| Code theme | github-dark (Shiki) | Markdown code blocks |

## Category Colors (CourseCard badges)

| Category | Classes |
|---|---|
| devops | `border-blue-500/30 bg-blue-900/50 text-blue-300` |
| cloud | `border-cyan-500/30 bg-cyan-900/50 text-cyan-300` |
| security | `border-red-500/30 bg-red-900/50 text-red-300` |
| automation | `border-purple-500/30 bg-purple-900/50 text-purple-300` |
| other | `border-slate-600/30 bg-slate-800 text-slate-300` |

## Adding a New Course

1. Create `src/content/courses/<slug>.md` with required frontmatter:
   ```yaml
   ---
   title: string
   description: string
   youtubeId: string        # YouTube video ID (not full URL)
   category: devops | cloud | security | automation | other
   tags: [string]
   order: number            # Position on home page (omit to exclude from featured)
   publishedAt: YYYY-MM-DD
   difficulty: beginner | intermediate | advanced
   resources:               # Optional
     - label: string
       url: https://...
   ---
   ```
2. The course appears automatically in `/cursos` and the RSS feed.
3. Featured on home if `order` is set.

## Deployment

Plain HTTP/80. SSL terminates at CloudFront (same pattern as agevega.com).

```bash
docker build -t academy-frontend .
docker run -p 80:80 academy-frontend
```

## Testing

- **Framework:** Vitest v4 (node environment)
- **Run:** `bun run test`
- **Tests:** `src/test/` — see TESTING.md
- 100% coverage is the goal — every new function needs a test, every bug fix needs a regression test
- Do NOT import `astro:content` in test files — Vitest cannot resolve virtual Astro modules; mirror Zod schemas inline instead
- Update `src/test/schema.test.ts` whenever `src/content.config.ts` schema changes

## Do NOT

- Use `entry.slug` — it's deprecated, use `entry.id.replace(/\.mdx?$/, '')`
- Add `@tailwindcss/typography` — `.content-body` in global.css handles markdown styles
- Add SSL certs to the container — CloudFront handles TLS termination
- Use SPA-style `try_files ... /index.html` — this is SSG, use `$uri $uri/ $uri.html =404`
- Install new npm/bun packages without explicit approval
