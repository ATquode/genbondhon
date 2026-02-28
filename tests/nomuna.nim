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

  # enum flag
  FilePermission* {.size: sizeof(cint), pure.} = enum
    read
    write
    execute

  FilePermissions* = set[FilePermission]

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

func requestPermission*(permission: FilePermission): string =
  case permission
  of FilePermission.read:
    result = "user"
  of FilePermission.write:
    result = "admin"
  of FilePermission.execute:
    result = "guest"

func getLeastPriviledgedPermission*(): FilePermission =
  FilePermission.read

func requestAccess*(requestedPermission: FilePermission, targetPath: string): bool =
  if targetPath == "/":
    return requestedPermission == FilePermission.read
  else:
    return requestedPermission == FilePermission.execute

proc addIntNum2*(a, b: int): int =
  return a + b

proc divMod*(a, b: int): (int, int) =
  ## Returns (quotient, remainder) when dividing a by b
  let q = a div b
  let r = a mod b
  return (q, r)

proc extendTo3D*(point: (int, int), zValue: int): (int, int, int) =
  ## Takes a 2-member tuple and returns a 3-member tuple
  let (x, y) = point # Unpacking the input tuple
  return (x, y, zValue)

#[ binding_api.nim

type IntArray* {.importc, header: "helper_types.h".} = object
  len*: cint
  data*: ptr UncheckedArray[cint]

proc malloc(size: int): pointer {.importc: "malloc", header: "<stdlib.h>".}

proc divMod*(a, b: cint): IntArray {.raises: [], exportc, cdecl, dynlib.} =
  let (val1, val2) = nomuna.divMod(a.int, b.int)
  let arr = cast[ptr UncheckedArray[cint]](malloc(sizeof(cint) * 2))
  arr[0] = val1.cint
  arr[1] = val2.cint
  result.len = 2
  result.data = arr
]#

#[ nomuna.h

typedef struct
{
    int len;
    int* data;
} IntArray;

IntArray divMod(int a, int b);
]#

#[ helper_types.h

#ifndef HELPER_TYPES_H
#define HELPER_TYPES_H

typedef struct
{
    int len;
    int* data;
} IntArray;

#endif /* HELPER_TYPES_H */
]#

#[
{
  "kind": "nkProcDef",
  "info": ["nomuna.nim", 157, 0],
  "sons": [
    {
      "kind": "nkPostfix",
      "info": ["nomuna.nim", 157, 11],
      "sons": [
        {
          "kind": "nkIdent",
          "info": ["nomuna.nim", 157, 11],
          "ident": "*",
          "typ": 
        },
        {
          "kind": "nkIdent",
          "info": ["nomuna.nim", 157, 5],
          "ident": "divMod",
          "typ": 
        }
      ],
      "typ": 
    },
    {
      "kind": "nkEmpty",
      "info": ["???", 0, -1],
      "typ": 
    },
    {
      "kind": "nkEmpty",
      "info": ["???", 0, -1],
      "typ": 
    },
    {
      "kind": "nkFormalParams",
      "info": ["nomuna.nim", 157, 12],
      "sons": [
        {
          "kind": "nkTupleConstr",
          "info": ["nomuna.nim", 157, 25],
          "sons": [
            {
              "kind": "nkIdent",
              "info": ["nomuna.nim", 157, 26],
              "ident": "int",
              "typ": 
            },
            {
              "kind": "nkIdent",
              "info": ["nomuna.nim", 157, 31],
              "ident": "int",
              "typ": 
            }
          ],
          "typ": 
        },
        {
          "kind": "nkIdentDefs",
          "info": ["nomuna.nim", 157, 13],
          "sons": [
            {
              "kind": "nkIdent",
              "info": ["nomuna.nim", 157, 13],
              "ident": "a",
              "typ": 
            },
            {
              "kind": "nkIdent",
              "info": ["nomuna.nim", 157, 16],
              "ident": "b",
              "typ": 
            },
            {
              "kind": "nkIdent",
              "info": ["nomuna.nim", 157, 19],
              "ident": "int",
              "typ": 
            },
            {
              "kind": "nkEmpty",
              "info": ["nomuna.nim", 157, 22],
              "typ": 
            }
          ],
          "typ": 
        }
      ],
      "typ": 
    }
  ],
  "typ": 
}
]#

# func getPermission*(username: string): FilePermissions =
#   if username == "admin":
#     result = {FilePermission.read, FilePermission.write, FilePermission.execute}
#   elif username == "user":
#     result = {FilePermission.read, FilePermission.execute}
#   else:
#     result = {FilePermission.execute}

# func requestPermission*(user: string, permission: FilePermission): bool =
#   case permission
#   of FilePermission.read:
#     return user == "user" or user == "admin"
#   of FilePermission.write:
#     return user == "admin"
#   of FilePermission.execute:
#     return true
