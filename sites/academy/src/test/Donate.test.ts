import { describe, it, expect } from 'vitest';
import { experimental_AstroContainer as AstroContainer } from 'astro/container';
import DonateSection from '../components/DonateSection.astro';

describe('DonateSection', () => {
  it('links each amount tier to paypal.me/agevega with an EUR amount', async () => {
    const container = await AstroContainer.create();
    const html = await container.renderToString(DonateSection);
    for (const amount of [2, 5, 15]) {
      expect(html).toContain(`https://paypal.me/agevega/${amount}EUR`);
    }
  });

  it('renders a custom-amount input wired to paypal.me/agevega', async () => {
    const container = await AstroContainer.create();
    const html = await container.renderToString(DonateSection);
    expect(html).toMatch(/data-paypal="https:\/\/paypal\.me\/agevega"/);
    expect(html).toMatch(/id="donate-custom-amount"/);
    // text input (not number) so the scroll wheel / spinners can't change the amount
    expect(html).toMatch(/id="donate-custom-amount"[^>]*type="text"/);
    expect(html).toMatch(/id="donate-custom-amount"[^>]*inputmode="decimal"/);
  });

  it('opens PayPal links in a new tab with rel=noopener', async () => {
    const container = await AstroContainer.create();
    const html = await container.renderToString(DonateSection);
    expect(html).toMatch(/target="_blank"[^>]*rel="noopener noreferrer"/);
  });

  it('labels PayPal links for screen readers (new-tab disclosure)', async () => {
    const container = await AstroContainer.create();
    const html = await container.renderToString(DonateSection);
    expect(html).toMatch(/aria-label="[^"]*PayPal[^"]*nueva pesta/);
  });
});
