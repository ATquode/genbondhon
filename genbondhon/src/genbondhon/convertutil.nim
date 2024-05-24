# SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
#
# SPDX-License-Identifier: MIT

import std/[strformat, tables]

const nimToCompatTypeTbl* = {"int": "cint"}.toTable

func convertNimToCompatType*(nimType: string, code: string): string =
  case nimType
  of "int":
    &"{code}.cint"
  else:
    ""
