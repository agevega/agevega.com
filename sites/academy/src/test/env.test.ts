import { describe, it, expect } from 'vitest';

/**
 * Verifies the envField contract declared in astro.config.mjs.
 *
 * - PUBLIC_APP_VERSION is optional with default 'Localhost' (canonical, see sites/CONVENTIONS.md).
 *
 * Mirror of landing's env.test.ts; ensures both sites enforce the same default
 * for the version tag rendered in the home hero. Without this guard, a regression
 * to 'dev' on either site would silently pass tests.
 */
describe('envField schema', () => {
  it('PUBLIC_APP_VERSION has default "Localhost"', async () => {
    const fs = await import('node:fs/promises');
    const path = await import('node:path');
    const configPath = path.resolve(__dirname, '../../astro.config.mjs');
    const content = await fs.readFile(configPath, 'utf-8');
    expect(content).toMatch(/PUBLIC_APP_VERSION[\s\S]*default:\s*'Localhost'/);
  });
});
