import { defineConfig, envField } from 'astro/config';
import tailwind from '@astrojs/tailwind';

// https://astro.build/config
export default defineConfig({
  integrations: [tailwind()],
  env: {
    schema: {
      PUBLIC_APP_VERSION: envField.string({ context: 'client', access: 'public', optional: true, default: 'dev' }),
    },
  },
});
