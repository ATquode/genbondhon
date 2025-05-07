// SPDX-FileCopyrightText: 2025 Rifat Hasan <atunutemp1@gmail.com>
//
// SPDX-License-Identifier: MIT

import { mount } from "svelte";
import "./app.css";
import App from "./App.svelte";
import { extraNoOp, noop, printCond, printStr, takeChar } from "./lib/nomuna";

noop();
extraNoOp();
const a = 7;
printCond(a === 7);
printCond(a !== 7);
takeChar("a".charCodeAt(0).toString());
printStr("nim");
printStr("hello ñíℳ");

const app = mount(App, {
  target: document.getElementById("app")!,
});

export default app;
