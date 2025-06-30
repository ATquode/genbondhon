# SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
#
# SPDX-License-Identifier: MIT

import std/[dirs, paths, unittest]
import
  ../../src/genbondhon/
    [currentconfig, parseutil, util, wrapperTranslator, wrapperGenerator]

let filePath = "tests/nomuna.nim".Path # Testament starts from parent of `tests` dir
origFile = filePath
moduleName = filePath.lastPathPart.splitFile.name.string
bindingDirPath = "bindingTest".Path
let wrappedFileName = "wrappedApi.nim"
let publicApis = filePath.parsePublicAPIs()
check publicApis.containsType("string")

let (wrappedApis, wrappableAST, unwrappableAST) =
  publicApis.translateToCompatibleWrapperApi()
let wrappedFile =
  wrappedApis.generateWrapperFile(wrappedFileName, wrappableAST, unwrappableAST)
let bindingApis = wrappedFile.parsePublicAPIs()
check bindingApis.containsType("bool")
check bindingApis.containsType("cstring")

dirs.removeDir(bindingDirPath)
