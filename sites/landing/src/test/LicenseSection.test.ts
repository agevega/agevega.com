import { describe, it, expect } from 'vitest';
import { experimental_AstroContainer as AstroContainer } from 'astro/container';
import LicenseSection from '../components/LicenseSection.astro';

describe('LicenseSection', () => {
  it('renders MIT License text from the LICENSE file', async () => {
    const container = await AstroContainer.create();
    const html = await container.renderToString(LicenseSection);
    expect(html).toContain('MIT License');
    expect(html).toContain('Alejandro Vega');
  });

  it('renders license content inside a <pre> element', async () => {
    const container = await AstroContainer.create();
    const html = await container.renderToString(LicenseSection);
    expect(html).toMatch(/<pre[^>]*>[\s\S]*MIT License[\s\S]*<\/pre>/);
  });
});
