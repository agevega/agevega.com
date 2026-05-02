# TESTING — landing

Test framework: **Vitest 4** running in `node` environment.
Component testing: **Astro Container API** (`experimental_AstroContainer`, stable since Astro 6).

## Run

```bash
cd sites/landing
PUBLIC_API_URL=https://stub.example.com bun run test
```

`PUBLIC_API_URL` is required because `envField` declares it `optional: false`. In CI, the workflow provides a stub. For local dev outside vitest, the value comes from `.env`.

## What's covered

| File | Tests | Type |
|---|---|---|
| `src/test/env.test.ts` | 2 | Schema contract — verifies envField definitions in `astro.config.mjs` haven't drifted |
| `src/test/build.test.ts` | 7 | **Build regression** — `dist/` contains expected HTML for every route (skips if no prior build) |
| `src/test/Navigation.test.ts` | 3 | Component — nav element, primary links, logo alt |
| `src/test/Hero.test.ts` | 2 | Component — section landmark, deployment version badge |
| `src/test/Footer.test.ts` | 2 | Component — copyright text, current year |

Total: **16 tests across 5 files**.

## Patterns

### Component tests via Astro Container API

```ts
import { describe, it, expect } from 'vitest';
import { experimental_AstroContainer as AstroContainer } from 'astro/container';
import MyComponent from '../components/MyComponent.astro';

describe('MyComponent', () => {
  it('renders expected output', async () => {
    const container = await AstroContainer.create();
    const html = await container.renderToString(MyComponent);
    expect(html).toContain('expected text');
  });
});
```

`renderToString` returns the SSR-generated HTML. Assertions run on string matching. No DOM mounting needed — Astro components are server-rendered, so `node` environment suffices.

### Why `getViteConfig`

`vitest.config.ts`:
```ts
import { getViteConfig } from 'astro/config';
import { defineConfig } from 'vitest/config';

export default getViteConfig(
  defineConfig({
    test: { environment: 'node', include: ['src/test/**/*.test.ts'] },
  }),
);
```

`getViteConfig` injects Astro's vite plugins (Astro compiler, env module, content collections, etc.) into vitest's resolver. Without it, imports of `*.astro` files fail because vitest doesn't know how to compile them.

### Build regression test

`build.test.ts` uses `it.skipIf(!distExists)` — if you run `bun run test` without first running `bun run build`, the regression tests skip silently rather than fail. CI workflow runs `bun run build && bun run test` to force the regression check.

## Adding tests

When adding a new component:
1. Create `src/test/<ComponentName>.test.ts` mirroring the existing pattern.
2. Use Container API for render-and-assert.
3. Spot-check the user-visible output (text, ARIA labels, links), not internal CSS classes (those break with style refactors).

When adding a new page:
1. Add the path to the `expectedPages` array in `build.test.ts`.

When adding a new env var:
1. Update `astro.config.mjs:env.schema`.
2. Update `.env.example` with the placeholder.
3. Add an assertion to `env.test.ts`.

## Do NOT

- Use `jsdom` environment unless a component needs the DOM (no current component does).
- Test against rendered CSS class names — Tailwind utility classes are an implementation detail. Test the user-visible content instead.
- Use the Astro Container API in places other than `src/test/`. It's a test-only API.
- Add tests for `astro:content` collections — landing has no content collections; that's an academy pattern.
