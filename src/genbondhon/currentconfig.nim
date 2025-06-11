# SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
#
# SPDX-License-Identifier: MIT

import std/paths
import compiler/options

const testDirPath* = "tests".Path
var showVerboseOutput* = false
var shouldUseVCCStr* = true
var origFile*: Path
var moduleName* = ""
var bindingDirPath*: Path
let configRef* = newConfigRef()
