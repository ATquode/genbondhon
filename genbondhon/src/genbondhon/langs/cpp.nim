# SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
#
# SPDX-License-Identifier: MIT

import std/[paths, strformat, strutils, terminal]
import compiler/ast
import base, c
import ../currentconfig

type CppLangGen = ref object of CLangGen

proc newCppLangGen*(bindingDir: Path): CppLangGen =
  ## `CppLangGen` constructor
  result = CppLangGen(
    langDir: bindingDir / "C++".Path, headerFileName: moduleName.Path.addFileExt("hpp")
  )
  initBaseLangGen(result)

func generateCppHeaderContent(headerName: string, bindingAST: seq[PNode]): string =
  let headerGuard = headerName.toUpperAscii & "_HPP"
  var cApis: seq[string]
  for api in bindingAST:
    let trApi = translateApi(api)
    cApis.add(trApi)
  result =
    &"""
#ifndef {headerGuard}
#define {headerGuard}

extern "C" {{
    {cApis.join("\n\n    ")}
}}

#endif /* {headerGuard} */
"""

proc generateCppHeader(self: CppLangGen, bindingAST: seq[PNode]) =
  let content = generateCppHeaderContent(moduleName, bindingAST)
  if showVerboseOutput:
    styledEcho fgGreen, "Cpp Header Content:"
    echo content
  let headerFilePath = self.langDir / self.headerFileName
  self.ensureDir()
  headerFilePath.string.writeFile(content)

method realTestDir(self: CppLangGen): Path =
  testDirPath / "C++".Path

method testCompileCode(self: CppLangGen): string =
  "testCode.cpp"

method staticLibBuildCmd(self: CppLangGen): string =
  &"nim cpp -d:release --noMain:on --app:staticlib --outdir:{self.langDir.string} {self.bindingModuleFile.string}"

method dynamicLibBuildCmd(self: CppLangGen): string =
  &"nim cpp -d:release --noMain:on --app:lib --outdir:{self.langDir.string} {self.bindingModuleFile.string}"

method compileTestCodeStaticLibCmd(self: CppLangGen, staticLibName: string): string =
  &"g++ {string self.realTestDir / self.testCompileCode.Path} {string self.realTestDir / staticLibName.Path}"

method compileTestCodeDynamicLibCmd(self: CppLangGen, dynamicLibName: string): string =
  &"g++ {string self.realTestDir / self.testCompileCode.Path} {string self.realTestDir / dynamicLibName.Path}"

method generateBinding*(self: CppLangGen, bindingAST: seq[PNode]) =
  ## Generates binding & documentation for C++
  self.generateCppHeader(bindingAST)
  self.generateReadMe()
