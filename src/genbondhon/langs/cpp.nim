# SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
#
# SPDX-License-Identifier: MIT

import std/[options, paths, sequtils, strformat, strutils, sugar, tables, terminal]
import compiler/ast
import base, c
import ../[convertutil, currentconfig, store, util]

type CppLangGen = ref object of CLangGen

proc newCppLangGen*(bindingDir: Path): CppLangGen =
  ## `CppLangGen` constructor
  result = CppLangGen(
    langDir: bindingDir / "C++".Path, headerFileName: moduleName.Path.addFileExt("hpp")
  )
  initBaseLangGen(result)

method translateEnum(self: CppLangGen, node: PNode): (string, string) =
  let enumName = node.itemName
  self.storeNamedType(enumName, NamedTypeCategory.enumType)
  let enumValsParent = node[2]
  var enumVals: seq[string]
  for i in 1 ..< enumValsParent.safeLen:
    let (enumValName, enumValVal) = enumValsParent[i].enumNameValue
    var val =
      &"""
    {enumValName.capitalizeAscii}"""
    if enumValVal.isSome:
      val = &"{val} = {enumValVal.unsafeGet}"
    enumVals.add(val)
  var trResult =
    &"""
enum class {enumName} {{
    {enumVals.join(",\n    ")}
}};"""
  let lastLineIndex = trResult.rfind("\n")
  trResult.insert("    ", lastLineIndex + 1)
  result = (enumName, trResult)

method convertEnumToEnumFlag(self: CppLangGen, enumBody: string): string =
  let enumBodyLines = enumBody.splitLines
  let itemLines = enumBodyLines[1 ..^ 2]
  let startPart =
    &"""// Use [magic_enum](https://github.com/Neargye/magic_enum),
    // or [bitwise-enum](https://github.com/jonesinator/bitwise-enum) to use bitwise operators
    {enumBodyLines[0]}"""
  # add NONE enum item
  let spaceCount =
    itemLines[0].len - itemLines[0].strip(trailing = false, chars = {' '}).len
  let noneLine = " ".repeat(spaceCount) & "None = 0,"
  var flagLines: seq[string] = @[noneLine]
  for i in 0 ..< itemLines.len:
    let enumVal = &"1 << {i}"
    var item = itemLines[i]
    if i == itemLines.len - 1:
      item.add(&" = {enumVal}")
    else:
      item.insert(&" = {enumVal}", item.len - 1)
    flagLines.add(item)
  result = concat(@[startPart], flagLines, @[enumBodyLines[^1]]).join("\n")

func generateCppHeaderContent(
    self: CppLangGen,
    headerName: string,
    bindingAST: seq[PNode],
    flagLookupTbl: Table[string, Table[string, string]],
): string =
  let headerGuard = headerName.toUpperAscii & "_HPP"
  var cppApis: OrderedTable[string, string]
  for api in bindingAST:
    let (apiId, trApi) = self.translateApi(api, flagLookupTbl)
    cppApis[apiId] = trApi
  cppApis = self.handleEnumFlags(cppApis)
  cppApis = collect(initOrderedTable):
    for k, v in cppApis.pairs:
      if v != "":
        {k: v}
  result =
    &"""
#ifndef {headerGuard}
#define {headerGuard}

extern "C" {{
    {cppApis.values.toseq.join("\n\n    ")}
}}

#endif /* {headerGuard} */
"""

proc generateCppHeader(self: CppLangGen, bindingAST: seq[PNode]) =
  let content =
    self.generateCppHeaderContent(moduleName, bindingAST, flagEnumRevrsLookupTbl)
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
