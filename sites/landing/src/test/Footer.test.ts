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

  it('uses max-w-7xl (matches landing section width)', async () => {
    const container = await AstroContainer.create();
    const html = await container.renderToString(Footer);
    expect(html).toMatch(/max-w-7xl/);
  });

  it('attributes content under MIT licence (not "todos los derechos reservados")', async () => {
    const container = await AstroContainer.create();
    const html = await container.renderToString(Footer);
    expect(html).toMatch(/MIT/);
    expect(html).not.toMatch(/[Tt]odos los derechos reservados/);
  });

  it('copyright text links to /license', async () => {
    const container = await AstroContainer.create();
    const html = await container.renderToString(Footer);
    expect(html).toMatch(/href="\/license"/);
    expect(html).toMatch(/Alejandro Vega — Contenido bajo licencia MIT/);
  });

  it('includes cross-site link to academy with rel=noopener and target=_blank', async () => {
    const container = await AstroContainer.create();
    const html = await container.renderToString(Footer);
    expect(html).toMatch(
      /href="https:\/\/academy\.agevega\.com"[^>]*target="_blank"[^>]*rel="noopener noreferrer"/,
    );
  });
});
