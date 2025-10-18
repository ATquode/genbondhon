# SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
#
# SPDX-License-Identifier: MIT

import std/strutils

type
  Direction* {.pure.} = enum
    north
    east
    south
    west

  MyEnum {.pure.} = enum
    valueA
    valueB

  GameState* {.pure.} = enum
    playing = 100
    pause
    game_over

  HttpStatusCode* {.pure.} = enum
    ok = 200
    created
    no_content = 204
    moved_permanently = 301
    found
    not_modified = 304
    bad_request = 400
    unauthorized
    forbidden = 403
    not_found
    internal_server_error = 500
    bad_gateway = 502
    service_unavailable

proc noop*() =
  echo "No Operation"

func makeSquareVal(x: int): int =
  x * x

proc extraNoOp*() =
  echo "extra: No Op."

proc modifyStr(str: string): string =
  let mstr = "$#!!" % [str]
  echo mstr
  return mstr

func constRet*(): int =
  return 2

func constRetBool*(): bool =
  return true

func constRetFloat*(): float =
  return 2.3

func constRetChar*(): char =
  return 'a'

func constRetStr*(): string =
  return "what"

func constRetUnicodeStr*(): string =
  return "প্রোগ্রামিং"

func addIntNum*(a: int, b: int): int =
  return a + b

proc printCond*(a: bool) =
  if a:
    echo "success"
  else:
    echo "failure"

func addDouble*(a: float, b: float): float =
  return a + b

func addFloat*(a: float32, b: float32): float32 =
  return a + b

proc takeChar*(a: char) =
  echo a

proc printStr*(a: string) =
  echo a

func sayHello*(name: string): string =
  "Héllø " & name

proc print2Str*(str1: string, str2: string) =
  echo str1, " ", str2

proc printDirectionRawValue*(direction: Direction) =
  echo "direction raw value: ", ord(direction)

func getDirection*(hint: string): Direction =
  if hint == "south": Direction.south else: Direction.east

func getOpposite*(direction: Direction): Direction =
  case direction
  of Direction.north:
    return Direction.south
  of Direction.east:
    return Direction.west
  of Direction.south:
    return Direction.north
  of Direction.west:
    return Direction.east

func togglePause*(curState: GameState): GameState =
  case curState
  of GameState.playing:
    return GameState.pause
  of GameState.pause:
    return GameState.playing
  else:
    return curState

func authenticate*(username: string): HttpStatusCode =
  if username in ["admin", "user"]:
    return HttpStatusCode.ok
  else:
    return HttpStatusCode.unauthorized

func setGameState*(username: string, state: GameState): HttpStatusCode =
  let authResult = username.authenticate
  if authResult == HttpStatusCode.unauthorized:
    return HttpStatusCode.forbidden
  if state == GameState.game_over:
    return HttpStatusCode.bad_request
  return HttpStatusCode.ok
