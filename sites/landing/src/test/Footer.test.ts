import { describe, it, expect } from 'vitest';
import { experimental_AstroContainer as AstroContainer } from 'astro/container';
import Footer from '../components/Footer.astro';

describe('Footer', () => {
  it('renders <footer> with copyright text', async () => {
    const container = await AstroContainer.create();
    const html = await container.renderToString(Footer);
    expect(html).toMatch(/<footer/);
    expect(html).toMatch(/AgeVega/);
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

  it('shows AgeVega copyright (not "todos los derechos reservados")', async () => {
    const container = await AstroContainer.create();
    const html = await container.renderToString(Footer);
    expect(html).toMatch(/AgeVega/);
    expect(html).toMatch(/©/);
    expect(html).not.toMatch(/[Tt]odos los derechos reservados/);
  });

  it('copyright text links to /license', async () => {
    const container = await AstroContainer.create();
    const html = await container.renderToString(Footer);
    expect(html).toMatch(/href="\/license"/);
    expect(html).toMatch(/AgeVega/);
  });

  it('shows the "Ingeniería de Plataformas" tagline', async () => {
    const container = await AstroContainer.create();
    const html = await container.renderToString(Footer);
    expect(html).toMatch(/Ingeniería de Plataformas/);
  });
});
