/**
 * Academy ESLint config — inlined (not extended from a shared config).
 *
 * Why inlined: ESLint v8 resolves parsers/plugins from the config file's
 * location, not the cwd. The monorepo has no root package.json / no root
 * node_modules, so a root-level shared config can't resolve
 * @typescript-eslint/parser or astro-eslint-parser.
 *
 * To keep both sites in lockstep, edit one and mirror the change to the
 * other. sites/CONVENTIONS.md documents this caveat.
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
