# SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
#
# SPDX-License-Identifier: MIT

import std/[dirs, paths, unittest]
import
  ../../src/genbondhon/
    [currentconfig, parseutil, wrapperTranslator, wrapperGenerator, util]

let filePath = "tests/nomuna.nim".Path # Testament starts from parent of `tests` dir
let publicApiCount = 15
origFile = filePath
moduleName = filePath.lastPathPart.splitFile.name.string
bindingDirPath = "bindingTest".Path
let wrappedFileName = "wrappedApi.nim"
let publicApis = filePath.parsePublicAPIs()
check publicApis.len == publicApiCount

const expectedPublicProcs = ["noop", "extraNoOp"]
for i in 0 ..< expectedPublicProcs.len:
  check publicApis[i].procName == expectedPublicProcs[i]

let wrappedApis = publicApis.translateToCompatibleWrapperApi()
let wrappedFile = wrappedApis.generateWrapperFile(wrappedFileName)
let bindingApis = wrappedFile.parsePublicAPIs()
check bindingApis.len == publicApiCount + 1 # public APIs + NimMain()

var expectedWrapperProcs = @["NimMain"]
expectedWrapperProcs.add(expectedPublicProcs)

for i in 0 ..< expectedWrapperProcs.len:
  check bindingApis[i].procName == expectedWrapperProcs[i]

dirs.removeDir(bindingDirPath)
