# SPDX-FileCopyrightText: 2025 Rifat Hasan <atunutemp1@gmail.com>
#
# SPDX-License-Identifier: MIT

import std/tables
import convertutil

const retTypeLookupKey* = "returnType"

var containsStringRet* = false
var containsEnum* = false
# To detect if the original nim code contains any tuple with 2 elements, called pair in C++
var containsPair* = false
# To detect if the original nim code contains any tuple with 3 or more elements, can be used as std::tuple in C++
var containsTuple* = false
var namedTypes*: Table[string, NamedTypeCategory]
var flagEnums*: seq[string]
var flagEnumSets*: Table[string, string]
var flagEnumRevrsLookupTbl*: Table[string, Table[string, string]]
var anonymousTuplesSigToName*: Table[string, string]
var anonymousTuplesNameToSig*: Table[string, string]
var anonymousTuplesCSig*: Table[string, string]
