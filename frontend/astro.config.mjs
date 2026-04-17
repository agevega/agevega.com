import { defineConfig, envField } from 'astro/config';
import tailwind from '@astrojs/tailwind';

// https://astro.build/config
export default defineConfig({
  site: 'https://agevega.com',
  integrations: [tailwind()],
  redirects: {
    '/': '/es/',
  },
  i18n: {
    defaultLocale: 'es',
    locales: ['es', 'en'],
    routing: {
      prefixDefaultLocale: true,
    },
  },
  env: {
    schema: {
      PUBLIC_APP_VERSION: envField.string({ context: 'client', access: 'public', optional: true, default: 'dev' }),
      PUBLIC_API_URL: envField.string({ context: 'client', access: 'public', optional: false }),
    },
  },
});
