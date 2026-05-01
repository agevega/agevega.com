# Changelog

All notable changes to this project will be documented in this file.

## [0.1.0] — 2026-04-30

### Added
- Full Astro 6 SSG frontend for AgeVega Academy (DevSecOps & Cloud courses)
- Tailwind v4 CSS-first design system with dark brand palette and emerald accent
- Content collection (`src/content/courses/`) with Zod schema validation
  - Required fields: title, description, youtubeId, category, tags, publishedAt
  - Optional: order (featured on home), difficulty (default: beginner), resources
  - HTTPS-only enforcement on resource URLs via `.refine()`
- Components: CourseCard, FilterBar (client-side search + category filter), HeroSection,
  Navigation, Footer, VideoEmbed (youtube-nocookie.com), ResourceList
- Pages: home (hero + featured), `/cursos` (full catalog + filter), `/cursos/[slug]`
  (individual course), 404, RSS feed
- Vitest v4 test suite with 9 schema validation tests (coverage: 9/10)
- GitHub Actions CI pipeline (`bun install --frozen-lockfile && bun run test`)
- Docker + Nginx deployment config (SSG pattern, 1-year asset cache)
- CLAUDE.md and TESTING.md project documentation

### Fixed
- FilterBar empty state visibility: `classList.toggle('hidden')` instead of inline
  `style.display` (inline style cannot override Tailwind `hidden` utility class)
