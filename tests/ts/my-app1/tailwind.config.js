// SPDX-FileCopyrightText: 2025 Rifat Hasan <atunutemp1@gmail.com>
//
// SPDX-License-Identifier: MIT

/** @type {import('tailwindcss').Config} */
import daisyui from "daisyui";
export default {
  content: ["./index.html", "./src/**/*.{svelte,js,ts,jsx,tsx}"],
  theme: {
    extend: {},
  },
  plugins: [daisyui],
};
