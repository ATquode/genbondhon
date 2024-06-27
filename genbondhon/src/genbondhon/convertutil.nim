# SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
#
# SPDX-License-Identifier: MIT

import std/[strformat, tables]

const nimAndCompatTypeTbl* = {
  "int": "cint",
  "float": "cdouble",
  "float32": "cfloat",
  "float64": "cdouble",
  "char": "cchar",
  "string": "cstring",
  "cint": "int",
  "cfloat": "float32",
  "cdouble": "float",
  "cchar": "char",
  "cstring": "string",
}.toTable

func convertNimAndCompatType*(origType: string, code: string): string =
  case origType
  of "int", "float", "float32", "float64", "char", "string", "cint", "cfloat",
      "cdouble", "cchar":
    &"{code}.{nimAndCompatTypeTbl[origType]}"
  of "cstring":
    &"${code}"
  else:
    code

const nimCompatToCTypeTbl* = {
  "cint": "int",
  "cfloat": "float",
  "cdouble": "double",
  "cchar": "char",
  "cstring": "const char*",
}.toTable

const nimCompatToCSharpTypeTbl* = {
  "cint": "int",
  "cfloat": "float",
  "cdouble": "double",
  "cchar": "char",
  "cstring": "string",
  "bool": "bool",
}.toTable
