/**
 * Landing ESLint config.
 *
 * Inlined (not extended from root) because ESLint v8 resolves parsers/plugins
 * from the location where they're declared, not where they're consumed. The
 * monorepo has no root package.json, so root-declared parsers can't resolve.
 *
 * To keep both sites in lockstep, edit `agevega.com/.eslintrc.cjs` (the
 * canonical reference) and copy the relevant changes here. CONVENTIONS.md
 * documents this caveat.
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
  ignorePatterns: ['node_modules/', 'dist/', '.astro/'],
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
