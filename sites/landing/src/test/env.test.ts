import { describe, it, expect } from 'vitest';

/**
 * Verifies the envField contract declared in astro.config.mjs.
 *
 * - PUBLIC_API_URL is required (no default).
 * - PUBLIC_APP_VERSION is optional with default 'dev'.
 *
 * If anyone changes envField definitions in astro.config.mjs without updating callers,
 * this test catches it (Astro itself fails the build if a required env var is missing,
 * but that's a build-time check; this test guards against schema drift in CI).
 */
describe('envField schema', () => {
  it('PUBLIC_API_URL is declared as required', async () => {
    // Read the raw config file content — we don't import the actual schema
    // because Astro env's schema is processed at build time.
    const fs = await import('node:fs/promises');
    const path = await import('node:path');
    const configPath = path.resolve(__dirname, '../../astro.config.mjs');
    const content = await fs.readFile(configPath, 'utf-8');
    expect(content).toMatch(/PUBLIC_API_URL.*optional:\s*false/s);
  });

  it('PUBLIC_APP_VERSION has default "dev"', async () => {
    const fs = await import('node:fs/promises');
    const path = await import('node:path');
    const configPath = path.resolve(__dirname, '../../astro.config.mjs');
    const content = await fs.readFile(configPath, 'utf-8');
    expect(content).toMatch(/PUBLIC_APP_VERSION[\s\S]*default:\s*'dev'/);
  });
});
