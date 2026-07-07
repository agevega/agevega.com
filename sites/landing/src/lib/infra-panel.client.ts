/**
 * infra-panel.client.ts — the browser glue for the live infra widgets.
 *
 * ONE copy of the fetch + timeout + populate logic, consumed by the
 * /about-this-web request trace (mountTrace). The truthfulness logic lives in
 * the pure `infra-panel.ts` module (unit-tested); this file only fetches and
 * writes to the DOM.
 *
 * Flow (fail-closed):
 *
 *   fetch('/meta.json', 2s AbortController)
 *      │
 *      ├─ !ok / abort / network error ─────► buildUnavailableView()  ("sin datos")
 *      ├─ body not JSON ──────────────────► buildUnavailableView()
 *      ├─ missing required field ─────────► buildUnavailableView()
 *      └─ valid ─► detectEnv(host, provider) ─► buildView()  (LIVE, or local if provider≠aws)
 *
 * 'unavailable' ≠ 'local': a fetch failure says nothing about the environment,
 * so the widget says "no data" instead of claiming to run locally.
 *
 * One shared, memoized fetch promise: even if several widgets ever co-render,
 * the page makes exactly one request to /meta.json.
 */

import {
  detectEnv,
  isValidMeta,
  buildView,
  buildUnavailableView,
  type CloudFrontInfo,
  type InfraStatus,
  type InfraView,
  type PerfInfo,
} from './infra-panel';

const META_URL = '/meta.json';
const TIMEOUT_MS = 2000;

let viewPromise: Promise<InfraView> | null = null;

/** Memoized single fetch shared by every widget on the page. */
function getView(): Promise<InfraView> {
  if (!viewPromise) viewPromise = fetchView();
  return viewPromise;
}

function readPerf(): PerfInfo {
  try {
    const nav = performance.getEntriesByType('navigation')[0] as
      | PerformanceNavigationTiming
      | undefined;
    if (!nav) return { ttfbMs: null, protocol: null };
    const ttfb = Math.round(nav.responseStart);
    return { ttfbMs: ttfb > 0 ? ttfb : null, protocol: nav.nextHopProtocol || null };
  } catch {
    return { ttfbMs: null, protocol: null };
  }
}

async function fetchView(): Promise<InfraView> {
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), TIMEOUT_MS);
  try {
    const res = await fetch(META_URL, {
      signal: controller.signal,
      headers: { Accept: 'application/json' },
    });
    if (!res.ok) return buildUnavailableView(readPerf());

    const headers: CloudFrontInfo = {
      pop: res.headers.get('x-amz-cf-pop'),
      cache: res.headers.get('x-cache'),
      via: res.headers.get('via'),
    };

    let data: unknown;
    try {
      data = await res.json();
    } catch {
      return buildUnavailableView(readPerf());
    }
    if (!isValidMeta(data)) return buildUnavailableView(readPerf());

    const env = detectEnv(location.hostname, data.provider);
    return buildView(data, headers, readPerf(), env);
  } catch {
    return buildUnavailableView(readPerf());
  } finally {
    clearTimeout(timer);
  }
}

// ---------------------------------------------------------------------------
// DOM helpers
// ---------------------------------------------------------------------------

function setText(root: ParentNode, field: string, value: string): void {
  const el = root.querySelector<HTMLElement>(`[data-field="${field}"]`);
  if (el) el.textContent = value;
}

function setState(root: HTMLElement, state: InfraStatus): void {
  root.dataset.state = state;
}

// The live dot is drawn by CSS (.trace[data-state='live'] .trace-badge::before),
// not as a text glyph — a ● character misaligns at 10px with letter-spacing.
const BADGE_LIVE = 'LIVE';
const BADGE_LOCAL = 'Local · Simulated';
const BADGE_UNAVAILABLE = 'Sin datos';

// ---------------------------------------------------------------------------
// /about-this-web request trace
// ---------------------------------------------------------------------------

export async function mountTrace(root: HTMLElement): Promise<void> {
  const view = await getView();
  renderTrace(root, view);
}

function renderTrace(root: HTMLElement, view: InfraView): void {
  const badge = root.querySelector<HTMLElement>('[data-trace-badge]');
  const envNote = root.querySelector<HTMLElement>('[data-trace-env]');

  // Performance API — the visitor's own request (live whenever available).
  setText(root, 'ttfb', view.perf.ttfbMs != null ? `${view.perf.ttfbMs} ms` : 'n/d');

  // The negotiated TLS version is not readable from browser JS, but the scheme
  // is — and https implies TLS. Read live, never asserted.
  setText(root, 'tls', location.protocol === 'https:' ? 'cifrado · https' : 'sin cifrar · http');

  if (view.status === 'live' && view.instance) {
    setState(root, 'live');
    if (badge) badge.textContent = BADGE_LIVE;
    setText(root, 'traceAz', view.instance.az);
    setText(root, 'traceType', view.instance.type);
    setText(root, 'traceRelease', view.release);
  } else if (view.status === 'unavailable') {
    setState(root, 'unavailable');
    if (badge) badge.textContent = BADGE_UNAVAILABLE;
    setText(root, 'traceAz', '—');
    setText(root, 'traceType', '—');
    setText(root, 'traceRelease', view.release);
  } else {
    setState(root, 'local');
    if (badge) badge.textContent = BADGE_LOCAL;
    setText(root, 'traceAz', '—');
    setText(root, 'traceType', '—');
    setText(root, 'traceRelease', view.release);
  }

  if (envNote) {
    if (view.status === 'unavailable') {
      // A fetch failure says nothing about the environment — claim nothing.
      envNote.textContent = 'No se pudieron leer los metadatos';
    } else if (view.env === 'dev') {
      envNote.textContent = 'Entorno de desarrollo: CloudFront → bastion (sin ALB/WAF delante).';
    } else if (view.env === 'local') {
      envNote.textContent =
        'Entorno local: sin CDN ni balanceador — los datos de instancia no aplican.';
    } else {
      envNote.textContent = 'Entorno real: producción en AWS — auditable en DevTools → Network.';
    }
  }
}
