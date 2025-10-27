# SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
#
# SPDX-License-Identifier: MIT

import std/[dirs, paths, unittest]
import
  ../../src/genbondhon/
    [currentconfig, parseutil, wrapperTranslator, wrapperGenerator, util]

let filePath = "tests/nomuna.nim".Path # Testament starts from parent of `tests` dir
let publicApiCount = 25
origFile = filePath
moduleName = filePath.lastPathPart.splitFile.name.string
bindingDirPath = "bindingTest".Path
let wrappedFileName = "wrappedApi.nim"
let publicApis = filePath.parsePublicAPIs()
check publicApis.len == publicApiCount

const expectedPublicNames =
  ["Direction", "GameState", "HttpStatusCode", "noop", "extraNoOp"]
for i in 0 ..< expectedPublicNames.len:
  check publicApis[i].itemName == expectedPublicNames[i]

let (wrappedApis, wrappableAST, unwrappableAST) =
  publicApis.translateToCompatibleWrapperApi()
let wrappedFile =
  wrappedApis.generateWrapperFile(wrappedFileName, wrappableAST, unwrappableAST)
let bindingApis = wrappedFile.parsePublicAPIs()
check bindingApis.len == publicApiCount + 1 - unwrappableAST.len
  # public APIs + NimMain() - Unwrappable APIs

var expectedWrapperProcs = @["NimMain"]
expectedWrapperProcs.add(
  expectedPublicNames.toOpenArray(3, expectedPublicNames.len - 1)
    # Drop Unwrappable APIs from `expectedPublicNames` - Direction, GameState etc.
)

for i in 0 ..< expectedWrapperProcs.len:
  check bindingApis[i].itemName == expectedWrapperProcs[i]

dirs.removeDir(bindingDirPath)
