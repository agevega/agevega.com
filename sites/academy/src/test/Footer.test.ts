import { describe, it, expect } from 'vitest';
import { experimental_AstroContainer as AstroContainer } from 'astro/container';
import Footer from '../components/Footer.astro';

describe('Footer', () => {
  it('renders <footer> with copyright text', async () => {
    const container = await AstroContainer.create();
    const html = await container.renderToString(Footer);
    expect(html).toMatch(/<footer/);
    expect(html).toMatch(/AgeVega Academy/);
  });

  it('shows the current year', async () => {
    const container = await AstroContainer.create();
    const html = await container.renderToString(Footer);
    const currentYear = new Date().getFullYear().toString();
    expect(html).toContain(currentYear);
  });

  it('uses max-w-7xl (canonical, aligned with nav, matches landing)', async () => {
    const container = await AstroContainer.create();
    const html = await container.renderToString(Footer);
    expect(html).toMatch(/max-w-7xl/);
  });

  it('attributes content under MIT licence', async () => {
    const container = await AstroContainer.create();
    const html = await container.renderToString(Footer);
    expect(html).toMatch(/MIT/);
  });

  it('contains a cross-site link to agevega.com', async () => {
    const container = await AstroContainer.create();
    const html = await container.renderToString(Footer);
    expect(html).toMatch(
      /href="https:\/\/agevega\.com"[^>]*target="_blank"[^>]*rel="noopener noreferrer"/,
    );
  });

  it('includes a support link to /donate', async () => {
    const container = await AstroContainer.create();
    const html = await container.renderToString(Footer);
    expect(html).toMatch(/href="\/donate"/);
    expect(html).toMatch(/Apóyame con un café/);
  });
});
