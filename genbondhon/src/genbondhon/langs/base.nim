# SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
#
# SPDX-License-Identifier: MIT

import std/[dirs, paths, strformat]
import compiler/ast
import ../currentconfig

type BaseLangGen* = ref object of RootObj
  langDir*: Path
  bindingModuleFile*: Path

proc initBaseLangGen*(self: BaseLangGen) =
  self.bindingModuleFile = bindingDirPath / moduleName.Path.addFileExt("nim")

method generateBinding*(self: BaseLangGen, bindingAST: seq[PNode]) {.base.} =
  discard

method getReadMeContent*(self: BaseLangGen): string {.base.} =
  result =
    &"""
### Compile
Compile `{self.bindingModuleFile.string}` instead of `{origFile.string}`."""

method generateReadMe*(self: BaseLangGen) {.base.} =
  let content = self.getReadMeContent()
  let readMeFile = self.langDir / "ReadMe.md".Path
  readMeFile.string.writeFile(content)

proc ensureDir*(self: BaseLangGen) =
  if not self.langDir.dirExists:
    self.langDir.createDir()
