import { describe, it, expect } from 'vitest';
import { experimental_AstroContainer as AstroContainer } from 'astro/container';
import AboutThisWeb from '../pages/about-this-web.astro';

/**
 * Smoke test for the /about-this-web page composition: the live request trace
 * renders first (carrying the page's only <h1>), the architecture overview
 * below it, with no id collisions and no fabricated values in the static HTML.
 */
async function render(): Promise<string> {
  const container = await AstroContainer.create();
  return container.renderToString(AboutThisWeb, {
    request: new Request('https://www.agevega.com/about-this-web'),
  });
}

describe('/about-this-web page', () => {
  it('renders both the architecture section and the request trace', async () => {
    const html = await render();
    expect(html).toMatch(/id="architecture"/);
    expect(html).toMatch(/id="request-trace"/);
  });

  it('renders the request trace BEFORE the architecture overview', async () => {
    const html = await render();
    const trace = html.indexOf('id="request-trace"');
    const architecture = html.indexOf('id="architecture"');
    expect(trace).toBeGreaterThan(-1);
    expect(architecture).toBeGreaterThan(-1);
    expect(trace).toBeLessThan(architecture);
  });

  it('has exactly one <h1> and it belongs to the request trace', async () => {
    const html = await render();
    expect((html.match(/<h1[\s>]/g) ?? []).length).toBe(1);
    const h1 = html.indexOf('<h1');
    expect(h1).toBeGreaterThan(html.indexOf('id="request-trace"'));
    expect(h1).toBeLessThan(html.indexOf('id="architecture"'));
  });

  it('does not collide ids between the two sections', async () => {
    const html = await render();
    expect((html.match(/id="request-trace"/g) ?? []).length).toBe(1);
    expect((html.match(/id="architecture"/g) ?? []).length).toBe(1);
  });

  it('ships no fabricated instance values in the static HTML', async () => {
    const html = await render();
    expect(html).not.toMatch(/i-[0-9a-f]{8,}/);
    expect(html).not.toContain('MAD56');
  });
});
