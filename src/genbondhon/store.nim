# SPDX-FileCopyrightText: 2025 Rifat Hasan <atunutemp1@gmail.com>
#
# SPDX-License-Identifier: MIT

import std/tables
import convertutil

const retTypeLookupKey* = "returnType"

var namedTypes*: Table[string, NamedTypeCategory]
var flagEnums*: seq[string]
var flagEnumSets*: Table[string, string]
var flagEnumRevrsLookupTbl*: Table[string, Table[string, string]]
