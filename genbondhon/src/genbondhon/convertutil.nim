# SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
#
# SPDX-License-Identifier: MIT

import std/[strformat, tables]

const nimToCompatTypeTbl* = {"bool": "cint", "int": "cint"}.toTable

func convertNimToCompatType*(nimType: string, code: string): string =
  case nimType
  of "bool", "int":
    &"{code}.cint"
  else:
    ""
