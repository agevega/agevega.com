/**
 * Shared ESLint config for the agevega.com monorepo.
 *
 * Each site under sites/ inherits this config (ESLint walks up the directory tree
 * to find it). To override per-app, add a .eslintrc.cjs inside the site directory.
 */
module.exports = {
  root: true,
  env: {
    browser: true,
    es2022: true,
    node: true,
  },
  extends: ['eslint:recommended'],
  parserOptions: {
    ecmaVersion: 'latest',
    sourceType: 'module',
  },
  ignorePatterns: [
    'node_modules/',
    'dist/',
    '.astro/',
    'infra/',
    '*.tfstate',
    '.github/',
  ],
  overrides: [
    {
      files: ['*.ts', '*.tsx'],
      parser: '@typescript-eslint/parser',
      plugins: ['@typescript-eslint'],
      extends: ['eslint:recommended', 'plugin:@typescript-eslint/recommended'],
      rules: {
        '@typescript-eslint/no-unused-vars': ['warn', { argsIgnorePattern: '^_' }],
      },
    },
    {
      files: ['*.astro'],
      parser: 'astro-eslint-parser',
      parserOptions: {
        parser: '@typescript-eslint/parser',
        extraFileExtensions: ['.astro'],
      },
      plugins: ['astro'],
      extends: ['plugin:astro/recommended'],
      rules: {},
    },
    {
      files: ['*.test.ts', '*.test.js', '**/test/**'],
      env: {
        node: true,
      },
    },
  ],
};
