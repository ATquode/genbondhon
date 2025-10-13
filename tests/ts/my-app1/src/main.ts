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
  getDirection,
  noop,
  print2Str,
  printCond,
  printDirectionRawValue,
  printStr,
  takeChar,
  togglePause,
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
let direction = Direction.South;
printDirectionRawValue(direction);
direction = getDirection("south");
console.log(`Direction: ${direction}`);
const gameState = GameState.Game_over;
console.log(`Game State: ${gameState}`);
const newGameState = togglePause(gameState);
console.log(`Game State: ${newGameState}`);

const app = mount(App, {
  target: document.getElementById("app")!,
});

export default app;
