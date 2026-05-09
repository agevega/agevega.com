import { describe, it, expect } from 'vitest';
import { experimental_AstroContainer as AstroContainer } from 'astro/container';
import Navigation from '../components/Navigation.astro';

async function renderAt(path: string): Promise<string> {
  const container = await AstroContainer.create();
  return container.renderToString(Navigation, {
    request: new Request(`https://academy.agevega.com${path}`),
  });
}

describe('Navigation', () => {
  it('renders <nav> with aria-label', async () => {
    const html = await renderAt('/');
    expect(html).toMatch(/<nav[^>]*aria-label=/);
  });

  it('renders AgeVega Academy text (no logo image)', async () => {
    const html = await renderAt('/');
    expect(html).toContain('AgeVega Academy');
    expect(html).not.toMatch(/<img[^>]*src="\/images\/logos/);
  });

  it('contains the two centered nav links', async () => {
    const html = await renderAt('/');
    expect(html).toMatch(/href="\/"/);
    expect(html).toMatch(/href="\/cursos"/);
  });

  it('uses max-w-7xl container (canonical, matches landing)', async () => {
    const html = await renderAt('/');
    expect(html).toMatch(/max-w-7xl/);
  });

  it('marks Inicio active on / (exact match)', async () => {
    const html = await renderAt('/');
    expect(html).toMatch(/href="\/"[^>]*aria-current="page"/);
    expect(html).not.toMatch(/href="\/cursos"[^>]*aria-current="page"/);
  });

  it('marks Cursos active on /cursos', async () => {
    const html = await renderAt('/cursos');
    expect(html).toMatch(/href="\/cursos"[^>]*aria-current="page"/);
    // Inicio must NOT be active when on /cursos (regression for startsWith collision)
    expect(html).not.toMatch(/href="\/"[^>]*aria-current="page"/);
  });

  it('marks Cursos active on nested /cursos/[slug]', async () => {
    const html = await renderAt('/cursos/aws-iam');
    expect(html).toMatch(/href="\/cursos"[^>]*aria-current="page"/);
    expect(html).toMatch(/href="\/cursos"[^>]*text-emerald-400/);
  });

  it('renders external Contacto CTA pointing to landing /contact', async () => {
    const html = await renderAt('/');
    expect(html).toMatch(
      /href="https:\/\/agevega\.com\/contact"[^>]*target="_blank"[^>]*rel="noopener noreferrer"/,
    );
  });

  it('CTA shows agevega.com label, has bg-emerald-600 and aria-label about new tab', async () => {
    const html = await renderAt('/');
    expect(html).toMatch(/href="https:\/\/agevega\.com\/contact"[^>]*bg-emerald-600/);
    expect(html).toMatch(/aria-label="agevega\.com[^"]*nueva pesta/);
    expect(html).toContain('agevega.com');
  });

  it('CTA does NOT show the ↗ glyph (regression: visual-noise removal)', async () => {
    const html = await renderAt('/');
    // Extract just the desktop CTA pill anchor and assert no ↗ inside
    const ctaMatch = html.match(
      /<a[^>]*href="https:\/\/agevega\.com\/contact"[^>]*bg-emerald-600[^>]*>([\s\S]*?)<\/a>/,
    );
    expect(ctaMatch, 'desktop CTA anchor must exist').not.toBeNull();
    expect(ctaMatch![1]).not.toContain('↗');
  });
});
