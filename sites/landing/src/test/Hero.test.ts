import { describe, it, expect } from 'vitest';
import { experimental_AstroContainer as AstroContainer } from 'astro/container';
import HeroSection from '../components/HeroSection.astro';

/**
 * Hero imports `astro:env/client` for PUBLIC_APP_VERSION. The default
 * declared in astro.config.mjs is 'dev', so the test environment gets
 * 'dev' without any setup.
 */
describe('HeroSection', () => {
  it('renders <section id="home"> as landmark', async () => {
    const container = await AstroContainer.create();
    const html = await container.renderToString(HeroSection);
    expect(html).toMatch(/<section[^>]*id="home"/);
  });

  it('includes a deployment version badge (PUBLIC_APP_VERSION)', async () => {
    const container = await AstroContainer.create();
    const html = await container.renderToString(HeroSection);
    // Version comes from astro:env/client. In dev/.env it's "Localhost",
    // in CI it's the git tag (e.g. "v1.1.0"), default fallback is "dev".
    // Just verify the version badge span exists with non-empty content.
    expect(html).toMatch(/<span[^>]*select-none[^>]*>\s*\S+\s*<\/span>/);
  });
});
