// SPDX-FileCopyrightText: 2025 Rifat Hasan <atunutemp1@gmail.com>
//
// SPDX-License-Identifier: MIT

import {
  addDouble,
  addFloat,
  addIntNum,
  constRet,
  constRetBool,
  constRetChar,
  constRetFloat,
  constRetStr,
  constRetUnicodeStr,
  extraNoOp,
  noop,
  printCond,
  takeChar,
  printStr,
  sayHello,
  print2Str,
  Direction,
  printDirectionRawValue,
  GameState,
  getOpposite,
  togglePause,
} from "./nomuna";

noop();
extraNoOp();
let a = constRet();
console.log(a);
let b = constRetBool();
console.log(b);
let c = constRetFloat();
console.log(c);
let d = constRetChar();
console.log(String.fromCharCode(parseInt(d)));
let e = constRetStr();
console.log(e);
let f = constRetUnicodeStr();
console.log(f);
let g = addIntNum(5, 3);
console.log(g);
printCond(g == 8);
printCond(g == 7);
let h = addDouble(5.03, 3.05);
console.log(h);
let i = addFloat(5.3, 3.5);
console.log(i);
let j = "a".charCodeAt(0).toString();
takeChar(j);
printStr("nim");
printStr("hello ñíℳ"); // Unicode
let k = sayHello("ñíℳ");
console.log(k);
print2Str("Hello", "World!");
let direction = Direction.South;
printDirectionRawValue(direction);
direction = getOpposite(Direction.North);
console.log(`Opposite of North: expected ${Direction.South}, got ${direction}`);
let gameState = GameState.Game_over;
console.log(`Game State: ${gameState}`);
let newGameState = togglePause(gameState);
console.log(`Game State: ${newGameState}`);
