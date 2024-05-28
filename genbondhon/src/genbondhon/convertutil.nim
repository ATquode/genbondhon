# SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
#
# SPDX-License-Identifier: MIT

import std/[strformat, tables]

const nimToCompatTypeTbl* = {
  "bool": "cint",
  "int": "cint",
  "float": "cdouble",
  "char": "cchar",
  "string": "cstring",
}.toTable

func convertNimAndCompatType*(origType: string, code: string): string =
  case origType
  of "bool", "int":
    &"{code}.cint"
  of "float":
    &"{code}.cdouble"
  of "char":
    &"{code}.cchar"
  of "string":
    &"{code}.cstring"
  of "cint":
    &"{code}.int"
  else:
    ""
