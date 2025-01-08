# SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
#
# SPDX-License-Identifier: MIT

import std/strutils

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
