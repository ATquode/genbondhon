# SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
#
# SPDX-License-Identifier: MIT

import std/strutils

proc noop*() =
  echo "No Operation"

func makeSquareVal(x: int): int =
  x * x

proc modifyStr(str: string): string =
  let mstr = "$#!!" % [str]
  echo mstr
  return mstr
