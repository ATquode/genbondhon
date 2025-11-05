// SPDX-FileCopyrightText: 2025 Rifat Hasan <atunutemp1@gmail.com>
//
// SPDX-License-Identifier: MIT

export enum Direction {
  North,
  East,
  South,
  West,
}

export enum GameState {
  Playing = 100,
  Pause,
  Game_over,
}

export enum HttpStatusCode {
  Ok = 200,
  Created,
  No_content = 204,
  Moved_permanently = 301,
  Found,
  Not_modified = 304,
  Bad_request = 400,
  Unauthorized,
  Forbidden = 403,
  Not_found,
  Internal_server_error = 500,
  Bad_gateway = 502,
  Service_unavailable,
}

export function noop();

export function extraNoOp();

export function constRet(): number;

export function constRetBool(): boolean;

export function constRetFloat(): number;

export function constRetChar(): string;

export function constRetStr(): string;

export function constRetUnicodeStr(): string;

export function addIntNum(a: number, b: number): number;

export function printCond(a: boolean);

export function addDouble(a: number, b: number): number;

export function addFloat(a: number, b: number): number;

export function takeChar(a: string);

export function printStr(a: string);

export function sayHello(name: string): string;

export function print2Str(str1: string, str2: string);

export function printDirectionRawValue(direction: Direction);

export function getDirection(hint: string): Direction;

export function getOpposite(direction: Direction): Direction;

export function togglePause(curState: GameState): GameState;

export function authenticate(username: string): HttpStatusCode;

export function setGameState(username: string, state: GameState): HttpStatusCode;
