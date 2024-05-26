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
