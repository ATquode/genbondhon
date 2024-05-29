# SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
#
# SPDX-License-Identifier: MIT

import std/[strformat, tables]

const nimAndCompatTypeTbl* = {
  "int": "cint", "float": "cdouble", "char": "cchar", "string": "cstring", "cint": "int"
}.toTable

func convertNimAndCompatType*(origType: string, code: string): string =
  case origType
  of "int", "float", "char", "string", "cint":
    &"{code}.{nimAndCompatTypeTbl[origType]}"
  else:
    code
