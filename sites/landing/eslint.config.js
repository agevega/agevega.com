/**
 * Landing ESLint config — flat config (ESLint 9).
 *
 * Migrated from .eslintrc.cjs (ESLint 8). The old inlined eslintrc could not
 * parse TypeScript inside `<script>` tags in .astro files; eslint-plugin-astro's
 * flat/recommended config wires astro-eslint-parser + typescript-eslint so that
 * frontmatter AND client `<script>` blocks are parsed as TS.
 *
 * Keep both sites in lockstep: edit one and mirror the change to the other.
 * sites/CONVENTIONS.md documents this caveat.
 */
import js from "@eslint/js";
import tseslint from "typescript-eslint";
import astro from "eslint-plugin-astro";
import globals from "globals";

export default [
  {
    ignores: ["node_modules/", "dist/", ".astro/"],
  },
  js.configs.recommended,
  ...tseslint.configs.recommended,
  ...astro.configs["flat/recommended"],
  {
    languageOptions: {
      ecmaVersion: "latest",
      sourceType: "module",
      globals: {
        ...globals.browser,
        ...globals.node,
      },
    },
    rules: {
      "@typescript-eslint/no-unused-vars": [
        "warn",
        {
          argsIgnorePattern: "^_",
          varsIgnorePattern: "^_",
          ignoreRestSiblings: true,
        },
      ],
    },
  },
];
