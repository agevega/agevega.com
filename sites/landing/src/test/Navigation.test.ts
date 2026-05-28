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

  it('contains the Contacto CTA link', async () => {
    const html = await renderAt('/');
    expect(html).toMatch(/href="\/contact"/);
  });

  it('includes the logo image with alt text', async () => {
    const html = await renderAt('/');
    expect(html).toMatch(/<img[^>]*alt="AV Logo"/);
  });

  it('renders nav inside max-w-7xl container (matches landing section width)', async () => {
    const html = await renderAt('/');
    expect(html).toMatch(/max-w-7xl/);
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
