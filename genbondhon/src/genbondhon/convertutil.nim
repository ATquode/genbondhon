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

const nimCompatAndSwiftTypeTbl* = {
  "cint": "Int",
  "cfloat": "Float",
  "cdouble": "Double",
  "cchar": "Character",
  "cstring": "String",
  "bool": "Bool",
  "Int": "CInt",
  "Float": "CFloat",
  "Double": "CDouble",
  "Character": "CChar",
}.toTable

func convertNimAndSwiftType*(origType: string, code: string): string =
  case origType
  of "cint", "cfloat", "cdouble", "bool", "Int", "Float", "Double":
    &"{nimCompatAndSwiftTypeTbl[origType]}({code})"
  of "cstring":
    &"String(cString: {code})"
  of "cchar":
    &"Character(UnicodeScalar(UInt8(bitPattern: {code})))"
  of "Character":
    &"String({code}).utf8CString[0]"
  else:
    code
