import { describe, it, expect } from 'vitest';
import { existsSync } from 'node:fs';
import { resolve } from 'node:path';

/**
 * Build regression test.
 *
 * Verifies that after `astro build`, the dist/ directory contains the expected
 * static HTML for every route defined in src/pages/. If a future change drops
 * a route or breaks the SSG pipeline, this fails immediately.
 *
 * This test SKIPS if dist/ is missing (e.g. test ran without prior build).
 * The CI workflow should run `bun run build` before `bun run test` to catch
 * regressions; locally it's optional but recommended.
 */
describe('build artifacts', () => {
  const dist = resolve(__dirname, '../../dist');
  const distExists = existsSync(dist);

  // Each entry: [path, description]
  const expectedPages: Array<[string, string]> = [
    ['index.html', 'home'],
    ['about/index.html', '/about'],
    ['about-this-web/index.html', '/about-this-web'],
    ['contact/index.html', '/contact'],
    ['donate/index.html', '/donate'],
    ['laboratory/index.html', '/laboratory'],
    ['404.html', '404 page (added Issue 4A)'],
  ];

  for (const [relPath, label] of expectedPages) {
    it.skipIf(!distExists)(`dist/${relPath} exists (${label})`, () => {
      expect(existsSync(`${dist}/${relPath}`)).toBe(true);
    });
  }

  it.skipIf(!distExists)('dist/_astro/ asset directory exists', () => {
    expect(existsSync(`${dist}/_astro`)).toBe(true);
  });
});
