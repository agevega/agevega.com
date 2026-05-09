// @ts-check
import { defineConfig, envField } from 'astro/config';
import tailwindcss from '@tailwindcss/vite';
import sitemap from '@astrojs/sitemap';

export default defineConfig({
  site: 'https://academy.agevega.com',
  server: { port: 4322, host: true },
  integrations: [sitemap()],
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
    },
  },
  markdown: {
    shikiConfig: {
      theme: 'github-dark',
    },
  },
});
