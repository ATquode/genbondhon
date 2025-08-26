// SPDX-FileCopyrightText: 2025 Rifat Hasan <atunutemp1@gmail.com>
//
// SPDX-License-Identifier: MIT

import { mount } from "svelte";
import "./app.css";
import App from "./App.svelte";
import {
  Direction,
  extraNoOp,
  GameState,
  noop,
  print2Str,
  printCond,
  printDirectionRawValue,
  printStr,
  takeChar,
} from "./lib/nomuna";

noop();
extraNoOp();
const a = 7;
printCond(a === 7);
printCond(a !== 7);
takeChar("a".charCodeAt(0).toString());
printStr("nim");
printStr("hello ñíℳ");
print2Str("Hello", "World!");
const direction = Direction.South;
printDirectionRawValue(direction);
const gameState = GameState.Game_over;
console.log(`Game State: ${gameState}`);

const app = mount(App, {
  target: document.getElementById("app")!,
});

export default app;
