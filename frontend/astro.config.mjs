import { defineConfig, envField } from 'astro/config';
import tailwind from '@astrojs/tailwind';

// https://astro.build/config
export default defineConfig({
  site: 'https://agevega.com',
  integrations: [tailwind()],
  i18n: {
    defaultLocale: 'es',
    locales: ['es', 'en'],
    routing: {
      prefixDefaultLocale: false,
    },
  },
  env: {
    schema: {
      PUBLIC_APP_VERSION: envField.string({ context: 'client', access: 'public', optional: true, default: 'dev' }),
      PUBLIC_API_URL: envField.string({ context: 'client', access: 'public', optional: false }),
    },
  },
});
