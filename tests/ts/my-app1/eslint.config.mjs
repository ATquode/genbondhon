// SPDX-FileCopyrightText: 2025 Rifat Hasan <atunutemp1@gmail.com>
//
// SPDX-License-Identifier: MIT

// @ts-check

import eslint from "@eslint/js";
import tseslint from "typescript-eslint";
import eslintPluginSvelte from "eslint-plugin-svelte";
import svelteConfig from "./svelte.config.js";
import * as svelteParser from "svelte-eslint-parser";
import * as typescriptParser from "@typescript-eslint/parser";

export default tseslint.config(
  eslint.configs.recommended,
  tseslint.configs.recommended,
  eslintPluginSvelte.configs["flat/recommended"],
  eslintPluginSvelte.configs["flat/prettier"],
  {
    files: ["**/*.svelte"],
    languageOptions: {
      parser: svelteParser,
      parserOptions: {
        parser: typescriptParser,
        project: "./tsconfig.app.json",
        extraFileExtensions: [".svelte"],
        svelteConfig,
      },
    },
  },
);
