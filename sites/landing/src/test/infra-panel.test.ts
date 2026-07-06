import { describe, it, expect } from 'vitest';
import {
  detectEnv,
  isValidMeta,
  buildView,
  buildFallbackView,
  buildUnavailableView,
  type MetaJson,
  type CloudFrontInfo,
  type PerfInfo,
} from '../lib/infra-panel';

/**
 * Pure truthfulness logic for the live infra widgets. These branches decide
 * whether the page tells the truth, so every one is covered here (the fetch +
 * DOM glue in infra-panel.client.ts is verified in-browser via /qa).
 */

const META: MetaJson = {
  provider: 'AWS',
  region: 'eu-south-2',
  availabilityZone: 'eu-south-2a',
  instanceId: 'i-01f0e8fae8f0b6097',
  instanceType: 't4g.nano',
  deploymentVersion: 'v1.8.3',
};

const HEADERS: CloudFrontInfo = { pop: 'MAD56-P2', cache: 'Miss from cloudfront', via: '1.1 cf' };
const PERF: PerfInfo = { ttfbMs: 43, protocol: 'h2' };

describe('detectEnv — hybrid by authority', () => {
  it('provider AWS + www → prod', () => {
    expect(detectEnv('www.agevega.com', 'AWS')).toBe('prod');
  });
  it('provider AWS + apex → prod', () => {
    expect(detectEnv('agevega.com', 'AWS')).toBe('prod');
  });
  it('provider AWS + dev. → dev (only hostname distinguishes prod from dev)', () => {
    expect(detectEnv('dev.agevega.com', 'AWS')).toBe('dev');
  });
  it('provider AWS + unknown host → prod (default; non-verifiable nodes stay inferred)', () => {
    expect(detectEnv('some-preview-host.example', 'AWS')).toBe('prod');
  });
  it('provider AWS is case-insensitive', () => {
    expect(detectEnv('www.agevega.com', 'aws')).toBe('prod');
  });
  it('provider local → local regardless of hostname (provider is the authority)', () => {
    expect(detectEnv('www.agevega.com', 'local')).toBe('local');
  });
  it('provider Localhost → local', () => {
    expect(detectEnv('dev.agevega.com', 'Localhost')).toBe('local');
  });
  it('provider empty / missing → local', () => {
    expect(detectEnv('www.agevega.com', '')).toBe('local');
    expect(detectEnv('www.agevega.com', undefined)).toBe('local');
    expect(detectEnv('www.agevega.com', null)).toBe('local');
  });
});

describe('isValidMeta', () => {
  it('accepts a full payload', () => {
    expect(isValidMeta(META)).toBe(true);
  });
  it('rejects a missing required field (instanceId)', () => {
    const { instanceId: _omit, ...rest } = META;
    expect(isValidMeta(rest)).toBe(false);
  });
  it('rejects an empty required field', () => {
    expect(isValidMeta({ ...META, availabilityZone: '   ' })).toBe(false);
  });
  it('rejects a missing instanceType', () => {
    const { instanceType: _omit, ...rest } = META;
    expect(isValidMeta(rest)).toBe(false);
  });
  it('rejects null / non-object', () => {
    expect(isValidMeta(null)).toBe(false);
    expect(isValidMeta('nope')).toBe(false);
    expect(isValidMeta(undefined)).toBe(false);
  });
});

describe('buildView', () => {
  it('prod + valid + headers → live with instance + cloudfront + perf', () => {
    const v = buildView(META, HEADERS, PERF, 'prod');
    expect(v.status).toBe('live');
    expect(v.env).toBe('prod');
    expect(v.instance).toEqual({
      id: 'i-01f0e8fae8f0b6097',
      az: 'eu-south-2a',
      type: 't4g.nano',
      region: 'eu-south-2',
    });
    expect(v.cloudfront.pop).toBe('MAD56-P2');
    expect(v.perf.ttfbMs).toBe(43);
    expect(v.release).toBe('v1.8.3');
  });

  it('body live + CloudFront headers absent → instance still live, CF node degrades (outside-voice P3 branch)', () => {
    const v = buildView(META, { pop: null, cache: null, via: null }, PERF, 'prod');
    expect(v.status).toBe('live'); // does NOT pull the whole panel to fallback
    expect(v.instance?.id).toBe('i-01f0e8fae8f0b6097');
    expect(v.cloudfront.pop).toBeNull(); // rendered as inferred by the client
  });

  it('env local → status local, instance null even though meta is present (never show real values locally)', () => {
    const v = buildView(META, HEADERS, PERF, 'local');
    expect(v.status).toBe('local');
    expect(v.instance).toBeNull();
  });

  it('perf protocol absent → passed through as null (rendered inferred)', () => {
    const v = buildView(META, HEADERS, { ttfbMs: null, protocol: null }, 'prod');
    expect(v.perf.protocol).toBeNull();
    expect(v.perf.ttfbMs).toBeNull();
  });
});

describe('buildFallbackView — the single honest fallback (3A fail-closed)', () => {
  it('never emits a real-looking value', () => {
    const v = buildFallbackView();
    expect(v.status).toBe('local');
    expect(v.instance).toBeNull();
    expect(v.cloudfront).toEqual({ pop: null, cache: null, via: null });
    expect(v.perf).toEqual({ ttfbMs: null, protocol: null });
  });

  it('threat assertion: a fallback view carries no instance id / az / type anywhere', () => {
    const serialized = JSON.stringify(buildFallbackView('local', 'Localhost'));
    expect(serialized).not.toMatch(/i-[0-9a-f]{8,}/);
    expect(serialized).not.toContain('eu-south-2');
    expect(serialized).not.toContain('t4g');
  });
});

describe('buildUnavailableView — fetch failure is NOT "local"', () => {
  it('reports unavailable, never claims a local environment', () => {
    const v = buildUnavailableView();
    expect(v.status).toBe('unavailable');
    expect(v.instance).toBeNull();
    expect(v.release).toBe('n/d');
    expect(v.cloudfront).toEqual({ pop: null, cache: null, via: null });
  });

  it('is distinct from the true-local fallback', () => {
    expect(buildUnavailableView().status).not.toBe(buildFallbackView().status);
  });

  it("keeps the visitor's own perf data — it is real even when /meta.json fails", () => {
    const v = buildUnavailableView({ ttfbMs: 43, protocol: 'h2' });
    expect(v.perf.ttfbMs).toBe(43);
    expect(v.perf.protocol).toBe('h2');
  });

  it('defaults perf to nulls when not provided', () => {
    expect(buildUnavailableView().perf).toEqual({ ttfbMs: null, protocol: null });
  });

  it('threat assertion: carries no real-looking value anywhere', () => {
    const serialized = JSON.stringify(buildUnavailableView());
    expect(serialized).not.toMatch(/i-[0-9a-f]{8,}/);
    expect(serialized).not.toContain('eu-south-2');
    expect(serialized).not.toContain('t4g');
  });
});
