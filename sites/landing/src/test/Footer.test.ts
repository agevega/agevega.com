import { describe, it, expect } from 'vitest';
import { experimental_AstroContainer as AstroContainer } from 'astro/container';
import Footer from '../components/Footer.astro';

describe('Footer', () => {
  it('renders <footer> with copyright text', async () => {
    const container = await AstroContainer.create();
    const html = await container.renderToString(Footer);
    expect(html).toMatch(/<footer/);
    expect(html).toMatch(/Alejandro Vega/);
  });

  it('shows the current year', async () => {
    const container = await AstroContainer.create();
    const html = await container.renderToString(Footer);
    const currentYear = new Date().getFullYear().toString();
    expect(html).toContain(currentYear);
  });
});
