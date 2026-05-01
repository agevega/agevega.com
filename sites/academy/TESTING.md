# TESTING

Philosophy: 100% test coverage is the key to great vibe coding. Tests let you move fast, trust your instincts, and ship with confidence — without them, vibe coding is just yolo coding. With tests, it's a superpower.

## Framework

**Vitest v4** — node environment, zero config overhead.

## Run tests

```bash
bun run test          # single run
bun run test --watch  # watch mode
```

## Test layers

| Layer | What | Where |
|-------|------|-------|
| Unit | Schema validation, pure functions | `src/test/` |
| Build | `bun run build` must succeed | manual / CI |
| E2E | Visual/browser QA | `/gstack-qa` |

## Conventions

- Test files: `src/test/*.test.ts`
- Assertions: `expect(x).toBe(y)`, `expect(x).toBeInstanceOf(Date)`
- No `astro:content` imports — mirror Zod schemas inline for unit tests (virtual module not available in Vitest node env)
- Schema tests mirror `src/content.config.ts` exactly; update both in sync
