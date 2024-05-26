# SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
#
# SPDX-License-Identifier: MIT

import std/[strformat, tables]

const nimToCompatTypeTbl* =
  {"bool": "cint", "int": "cint", "float": "cdouble", "char": "cchar"}.toTable

func convertNimToCompatType*(nimType: string, code: string): string =
  case nimType
  of "bool", "int":
    &"{code}.cint"
  of "float":
    &"{code}.cdouble"
  of "char":
    &"{code}.cchar"
  else:
    ""
