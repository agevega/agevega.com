import { describe, it, expect } from 'vitest';
import { experimental_AstroContainer as AstroContainer } from 'astro/container';
import Navigation from '../components/Navigation.astro';

async function renderAt(path: string): Promise<string> {
  const container = await AstroContainer.create();
  return container.renderToString(Navigation, {
    request: new Request(`https://www.agevega.com${path}`),
  });
}

describe('Navigation', () => {
  it('renders <nav> element with main aria-label', async () => {
    const html = await renderAt('/');
    expect(html).toMatch(/<nav[^>]*aria-label=/);
  });

  it('contains expected primary nav links', async () => {
    const html = await renderAt('/');
    expect(html).toMatch(/href="\/"/);
    expect(html).toMatch(/href="\/about"/);
    expect(html).toMatch(/href="\/about-this-web"/);
    expect(html).toMatch(/href="\/contact"/);
    expect(html).toMatch(/href="\/laboratory"/);
  });

  it('includes the logo image with alt text', async () => {
    const html = await renderAt('/');
    expect(html).toMatch(/<img[^>]*alt="AV Logo"/);
  });

  it('renders nav inside max-w-7xl container (matches landing section width)', async () => {
    const html = await renderAt('/');
    expect(html).toMatch(/max-w-7xl/);
  });

  it('marks /about active and /about-this-web inactive when on /about', async () => {
    const html = await renderAt('/about');
    // /about anchor must have active classes and aria-current
    expect(html).toMatch(/href="\/about"[^>]*aria-current="page"/);
    expect(html).toMatch(/href="\/about"[^>]*text-emerald-400/);
    // /about-this-web must NOT be active (regression for predicate collision)
    expect(html).not.toMatch(/href="\/about-this-web"[^>]*aria-current="page"/);
  });

  it('marks /about-this-web active and /about inactive when on /about-this-web', async () => {
    const html = await renderAt('/about-this-web');
    expect(html).toMatch(/href="\/about-this-web"[^>]*aria-current="page"/);
    // The shorter /about path must NOT be marked active by accident
    expect(html).not.toMatch(/href="\/about"[^>]*aria-current="page"/);
  });

  it('marks Inicio active on / (exact match)', async () => {
    const html = await renderAt('/');
    expect(html).toMatch(/href="\/"[^>]*aria-current="page"/);
    expect(html).not.toMatch(/href="\/about"[^>]*aria-current="page"/);
  });

  it('CTA Contacto has bg-emerald-600 and href=/contact', async () => {
    const html = await renderAt('/');
    expect(html).toMatch(/href="\/contact"[^>]*bg-emerald-600/);
  });

  it('does not include the legacy setActiveLink JS class hooks', async () => {
    const html = await renderAt('/');
    // SSR replaces JS-driven active class injection; the .nav-link class hook
    // for client-side highlighting should be gone
    expect(html).not.toMatch(/class="nav-link\s/);
  });
});
