# SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
#
# SPDX-License-Identifier: MIT

import std/[strformat, tables]

type ConvertDirection* {.pure.} = enum
  fromC
  toC

type NamedTypeCategory* {.pure.} = enum
  noneType
  enumType
  setType

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

func convertNimAndCompatType*(
    origType: string, code: string, isFlagEnum: bool, convertDirection: ConvertDirection
): string =
  case origType
  of "int", "float", "float32", "float64", "char", "string", "cint", "cfloat",
      "cdouble", "cchar":
    &"{code}.{nimAndCompatTypeTbl[origType]}"
  of "cstring":
    &"${code}"
  else:
    if isFlagEnum:
      if convertDirection == ConvertDirection.fromC:
        &"cast[{origType}]({code}.int).toSeq()[0]"
      else:
        &"cast[cint]({{{code}}}.{origType})"
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

func convertNimAndSwiftType*(
    origType: string,
    code: string,
    convertDirection: ConvertDirection,
    moduleName: string,
    namedTypeCategory: NamedTypeCategory,
): string =
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
    case namedTypeCategory
    of NamedTypeCategory.enumType:
      if convertDirection == ConvertDirection.toC:
        &"{moduleName}.{origType}({code}.rawValue)"
      else:
        &"{origType}(rawValue: {code}.rawValue)"
    else:
      code

const nimCompatAndJNITypeTbl* = {
  "cint": "jint",
  "cfloat": "jfloat",
  "cdouble": "jdouble",
  "cchar": "jchar",
  "cstring": "jstring",
  "bool": "jboolean",
  "jint": "int",
  "jfloat": "float",
  "jdouble": "double",
  "jchar": "char",
  "jboolean": "bool",
}.toTable

func convertNimAndJNIType*(
    origType: string, code: string, namedTypeCategory: NamedTypeCategory
): string =
  case origType
  of "cint", "cfloat", "cdouble", "cchar", "bool", "jint", "jfloat", "jdouble", "jchar",
      "jboolean":
    &"({nimCompatAndJNITypeTbl[origType]}){code}"
  of "cstring":
    &"env->NewStringUTF({code})"
  else:
    case namedTypeCategory
    of NamedTypeCategory.enumType:
      &"static_cast<jint>({code})"
    else:
      code

const nimCompatToKotlinTypeTbl* = {
  "cint": "Int",
  "cfloat": "Float",
  "cdouble": "Double",
  "cchar": "Char",
  "cstring": "String",
  "bool": "Boolean",
}.toTable

const nimCompatToTypeScriptTypeTbl* = {
  "cint": "number",
  "cfloat": "number",
  "cdouble": "number",
  "cchar": "string",
  "cstring": "string",
  "bool": "boolean",
}.toTable
