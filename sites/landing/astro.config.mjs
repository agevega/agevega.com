// @ts-check
import { defineConfig, envField } from 'astro/config';
import tailwindcss from '@tailwindcss/vite';

// https://astro.build/config
export default defineConfig({
  site: 'https://agevega.com',
  vite: {
    plugins: [tailwindcss()],
  },
  env: {
    schema: {
      PUBLIC_APP_VERSION: envField.string({
        context: 'client',
        access: 'public',
        optional: true,
        default: 'Localhost',
      }),
      PUBLIC_API_URL: envField.string({
        context: 'client',
        access: 'public',
        optional: false,
      }),
    },
  },
});
