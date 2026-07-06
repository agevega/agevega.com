import { describe, it, expect } from 'vitest';
import { experimental_AstroContainer as AstroContainer } from 'astro/container';
import RequestTraceSection from '../components/RequestTraceSection.astro';

/**
 * The live request trace (rendered on /about-this-web). The static HTML
 * must ship ONLY placeholders; real values arrive at runtime via
 * infra-panel.client.ts. This test guards against anyone hardcoding a value.
 */
async function render(): Promise<string> {
  const container = await AstroContainer.create();
  return container.renderToString(RequestTraceSection);
}

describe('RequestTraceSection', () => {
  it('renders <section id="request-trace"> in the loading state', async () => {
    const html = await render();
    expect(html).toMatch(/<section[^>]*id="request-trace"/);
    expect(html).toMatch(/data-state="loading"/);
  });

  it('renders all six hops of the production chain (WAF as a CloudFront sub-line)', async () => {
    const html = await render();
    for (const node of ['Tú', 'CloudFront', 'AWS WAF', 'ALB', 'EC2', 'Nginx · Docker', 'Release']) {
      expect(html).toContain(node);
    }
  });

  it('exposes the live data-field hooks for the client to populate', async () => {
    const html = await render();
    for (const field of ['ttfb', 'tls', 'traceAz', 'traceType', 'traceRelease']) {
      expect(html).toMatch(new RegExp(`data-field="${field}"`));
    }
    // Removed on purpose — must NOT come back: protocol (h2/h3 noise),
    // CloudFront pop/x-cache, and the instance id.
    for (const gone of ['protocol', 'pop', 'cache', 'traceInstanceId']) {
      expect(html).not.toMatch(new RegExp(`data-field="${gone}"`));
    }
  });

  it('wraps the dynamic hops in an aria-live region', async () => {
    const html = await render();
    expect(html).toMatch(/aria-live="polite"/);
  });

  it('labels honesty classes (LIVE / inferido / estático)', async () => {
    const html = await render();
    expect(html).toContain('LIVE');
    expect(html).toContain('inferido');
    expect(html).toContain('estático');
  });

  it('ships NO fabricated values in the static HTML', async () => {
    const html = await render();
    expect(html).not.toMatch(/i-[0-9a-f]{8,}/); // instance id
    expect(html).not.toContain('eu-south-2'); // region / az
    expect(html).not.toContain('MAD56'); // CloudFront POP
    expect(html).not.toContain('t4g.nano'); // instance type
  });
});
