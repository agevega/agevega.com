import { describe, it, expect } from 'vitest';
import { experimental_AstroContainer as AstroContainer } from 'astro/container';
import Navigation from '../components/Navigation.astro';

describe('Navigation', () => {
  it('renders <nav> element with main aria-label', async () => {
    const container = await AstroContainer.create();
    const html = await container.renderToString(Navigation);
    expect(html).toMatch(/<nav[^>]*aria-label=/);
  });

  it('contains expected primary nav links', async () => {
    const container = await AstroContainer.create();
    const html = await container.renderToString(Navigation);
    // Spot-check the routes that appear in landing's IA
    expect(html).toMatch(/href="\/"/);
    expect(html).toMatch(/href="\/about"/);
    expect(html).toMatch(/href="\/about-this-web"/);
    expect(html).toMatch(/href="\/contact"/);
    expect(html).toMatch(/href="\/laboratory"/);
  });

  it('includes the logo image with alt text', async () => {
    const container = await AstroContainer.create();
    const html = await container.renderToString(Navigation);
    expect(html).toMatch(/<img[^>]*alt="AV Logo"/);
  });
});
