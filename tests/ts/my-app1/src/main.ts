// SPDX-FileCopyrightText: 2025 Rifat Hasan <atunutemp1@gmail.com>
//
// SPDX-License-Identifier: MIT

import { mount } from "svelte";
import "./app.css";
import App from "./App.svelte";
import {
  authenticate,
  Direction,
  extraNoOp,
  FilePermission,
  GameState,
  getDirection,
  getLeastPriviledgedPermission,
  noop,
  print2Str,
  printCond,
  printDirectionRawValue,
  printStr,
  requestPermission,
  setGameState,
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
let statusCode = authenticate("user1");
console.log(`Status code: ${statusCode}`);
statusCode = setGameState("user", GameState.Game_over);
console.log(`set Game State result: ${statusCode}`);
const newUser = requestPermission(FilePermission.Write);
console.log(
  `${newUser} has permission value: 0x${FilePermission.Write.toString(
    16,
  ).padStart(2, "0")}`,
);
const permission = getLeastPriviledgedPermission();
console.log(
  `Least priviledged permission value: 0x${permission
    .toString(16)
    .padStart(2, "0")}`,
);

const app = mount(App, {
  target: document.getElementById("app")!,
});

export default app;
