/**
 * infra-panel.ts — PURE logic for the live infrastructure evidence widgets.
 *
 * No DOM, no network, no browser globals. Everything here is unit-testable in
 * node/vitest. The fetch + DOM glue lives in `infra-panel.client.ts`; the truth
 * of "what does the page show" lives HERE, where it can be tested branch by
 * branch.
 *
 * Honesty contract: every value rendered from this module is either LIVE (read
 * from /meta.json, response headers, or the Performance API of the visitor's own
 * request) or explicitly labeled as inferred/local. Never a fabricated value.
 *
 * Environment detection — hybrid by authority:
 *
 *   provider (from /meta.json, written by IMDSv2 at container start)
 *      │  authority for AWS-vs-local — it cannot lie about where it runs
 *      ▼
 *   provider !== "aws" ──────────────────────────► local  (Local / Simulated)
 *      │
 *   provider === "aws"
 *      │   hostname is the ONLY signal that separates prod from dev
 *      ▼
 *   hostname starts "dev." ──► dev (CloudFront → bastion, no ALB/WAF)
 *   else (www / apex / unknown) ──► prod (full chain)
 *
 * Unknown hostnames default to prod, but the non-verifiable nodes (WAF, ALB,
 * CloudFront-edge when its headers are absent) are always rendered as INFERRED,
 * never asserted as live — so an unrecognized host fabricates nothing.
 */

export interface MetaJson {
  provider: string;
  region: string;
  availabilityZone: string;
  instanceId: string;
  instanceType: string;
  deploymentVersion: string;
}

export type Env = 'prod' | 'dev' | 'local';

/** CloudFront edge data, read from the /meta.json response headers. */
export interface CloudFrontInfo {
  /** x-amz-cf-pop, e.g. "MAD56-P2". null when the header is absent (local/preview). */
  pop: string | null;
  /** x-cache, e.g. "Miss from cloudfront". null when absent. */
  cache: string | null;
  /** via header. null when absent. */
  via: string | null;
}

/** The visitor's own request timing, read from the Performance API. */
export interface PerfInfo {
  /** Time to first byte in ms, or null when unavailable. */
  ttfbMs: number | null;
  /** nextHopProtocol, e.g. "h2". null when the browser does not expose it. */
  protocol: string | null;
}

export interface InstanceInfo {
  id: string;
  az: string;
  type: string;
  region: string;
}

/**
 * The view-model the widgets consume. `status` drives the visual treatment:
 *  - 'live'        → real instance data, LIVE badge
 *  - 'local'       → provider says non-AWS: honest "Local (Simulated)" state
 *  - 'unavailable' → /meta.json could not be read (timeout, non-200, malformed,
 *                    missing field). We know NOTHING about the environment, so
 *                    we say exactly that — never "local", which could be false
 *                    on a production fetch failure.
 */
export type InfraStatus = 'live' | 'local' | 'unavailable';

export interface InfraView {
  status: InfraStatus;
  env: Env;
  /** null in local/fallback — we never invent instance values. */
  instance: InstanceInfo | null;
  /** Release string (meta.deploymentVersion live, or a fallback label). */
  release: string;
  /** pop/cache/via — any field null is rendered as inferred ("vía CloudFront"). */
  cloudfront: CloudFrontInfo;
  perf: PerfInfo;
}

const EMPTY_CLOUDFRONT: CloudFrontInfo = { pop: null, cache: null, via: null };
const EMPTY_PERF: PerfInfo = { ttfbMs: null, protocol: null };

/**
 * Decide the environment. `provider` is the authority for AWS-vs-local;
 * `hostname` only separates prod from dev (meta.json cannot — both are real AWS).
 */
export function detectEnv(
  hostname: string | null | undefined,
  provider: string | null | undefined,
): Env {
  const p = (provider ?? '').trim().toLowerCase();
  // provider is authority for AWS-vs-local: anything that is not AWS is local.
  if (p !== 'aws') return 'local';
  const h = (hostname ?? '').trim().toLowerCase();
  if (h.startsWith('dev.')) return 'dev';
  // www / apex / unknown all map to the full prod chain (non-verifiable nodes
  // stay inferred, so unknown never fabricates).
  return 'prod';
}

/** Type guard: a /meta.json payload is usable only if the required fields are present, non-empty strings. */
export function isValidMeta(data: unknown): data is MetaJson {
  if (!data || typeof data !== 'object') return false;
  const m = data as Record<string, unknown>;
  const required = ['instanceId', 'availabilityZone', 'instanceType'] as const;
  return required.every((k) => typeof m[k] === 'string' && (m[k] as string).trim().length > 0);
}

/**
 * Build the view-model from validated, live inputs.
 *
 * env is computed by the caller via detectEnv(hostname, meta.provider). When env
 * is 'local' the widget renders the honest local state even though `meta` is
 * present (e.g. provider says local). When env is prod/dev the instance fields
 * are live.
 */
export function buildView(
  meta: MetaJson,
  headers: CloudFrontInfo,
  perf: PerfInfo,
  env: Env,
): InfraView {
  if (env === 'local') {
    // provider is not AWS — tell the truth, do not show real-looking values.
    return buildFallbackView('local', meta.deploymentVersion || 'Localhost');
  }
  return {
    status: 'live',
    env,
    instance: {
      id: meta.instanceId,
      az: meta.availabilityZone,
      type: meta.instanceType,
      region: meta.region,
    },
    release: meta.deploymentVersion || 'Localhost',
    // pop/cache/via may individually be null → rendered as inferred.
    cloudfront: { pop: headers.pop, cache: headers.cache, via: headers.via },
    perf: { ttfbMs: perf.ttfbMs, protocol: perf.protocol },
  };
}

/**
 * The honest state for a TRUE local run (meta.json read fine, provider ≠ aws).
 * Never emits a real-looking value.
 */
export function buildFallbackView(env: Env = 'local', release = 'Localhost'): InfraView {
  return {
    status: 'local',
    env,
    instance: null,
    release,
    cloudfront: { ...EMPTY_CLOUDFRONT },
    perf: { ...EMPTY_PERF },
  };
}

/**
 * The honest state when /meta.json could not be read at all (timeout, non-200,
 * malformed JSON, missing required field). Distinct from 'local': claiming
 * "local environment" on a production fetch failure would be a lie. The
 * visitor's own perf data (TTFB) is still real and may be shown.
 */
export function buildUnavailableView(perf: PerfInfo = { ...EMPTY_PERF }): InfraView {
  return {
    status: 'unavailable',
    env: 'local', // unknown — renderers must not derive claims from env here
    instance: null,
    release: 'n/d',
    cloudfront: { ...EMPTY_CLOUDFRONT },
    perf: { ttfbMs: perf.ttfbMs, protocol: perf.protocol },
  };
}
