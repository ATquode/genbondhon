# SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
#
# SPDX-License-Identifier: MIT

import std/[dirs, paths, strutils]
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
assert publicApis.len == publicApiCount,
  "The number of public Apis ($#) don't match".format(publicApis.len)

const expectedPublicProcs = ["noop", "extraNoOp"]
for i in 0 ..< expectedPublicProcs.len:
  assert publicApis[i].procName == expectedPublicProcs[i],
    "$# doesn't match $#".format(publicApis[i].procName, expectedPublicProcs[i])

let wrappedApis = publicApis.translateToCompatibleWrapperApi()
let wrappedFile = wrappedApis.generateWrapperFile(wrappedFileName)
let bindingApis = wrappedFile.parsePublicAPIs()
assert bindingApis.len == publicApiCount

for i in 0 ..< expectedPublicProcs.len:
  assert bindingApis[i].procName == expectedPublicProcs[i],
    "$# doesn't match $#".format(bindingApis[i].procName, expectedPublicProcs[i])

dirs.removeDir(bindingDirPath)
