# SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
#
# SPDX-License-Identifier: MIT

import std/[options, paths, sequtils, strformat, strutils, sugar, tables, terminal]
import compiler/ast
import base
import ../[convertutil, currentconfig, util]

type CLangGen* = ref object of BaseLangGen
  headerFileName*: Path

proc newCLangGen*(bindingDir: Path): CLangGen =
  ## `CLangGen` constructor
  result = CLangGen(
    langDir: bindingDir / "C".Path, headerFileName: moduleName.Path.addFileExt("h")
  )
  initBaseLangGen(result)

func replaceType(nimCType: string): string =
  ## Replaces Nim Compat Types to C Types
  nimCompatToCTypeTbl.getOrDefault(nimCType, nimCType)

method translateEnum(self: CLangGen, node: PNode): (string, string) =
  let enumName = node.itemName
  self.storeNamedType(enumName, NamedTypeCategory.enumType)
  let enumValsParent = node[2]
  var enumVals: seq[string]
  for i in 1 ..< enumValsParent.safeLen:
    let (enumValName, enumValVal) = enumValsParent[i].enumNameValue
    var val =
      &"""
    {enumValName.toUpperAscii}"""
    if enumValVal.isSome:
      val = &"{val} = {enumValVal.unsafeGet}"
    enumVals.add(val)
  let trResult =
    &"""
typedef enum {{
{enumVals.join(",\n")}
}} {enumName};"""
  result = (enumName, trResult)

func translateProc(node: PNode): (string, string) =
  let funcName = node.itemName
  let paramNode = procParamNode(node)
  var retType = "void"
  var trParamList: seq[string]
  if paramNode.isSome:
    let formalParamNode = paramNode.get()
    for i in 1 ..< formalParamNode.safeLen:
      let paramName = formalParamNode[i].paramName
      let paramType = formalParamNode[i].paramType
      let trParam = &"{paramType.replaceType} {paramName}"
      trParamList.add(trParam)
    if formalParamNode[0].kind != nkEmpty:
      retType = formalParamNode[0].ident.s
  let trResult =
    &"""
{retType.replaceType} {funcName}({trParamList.join(", ")});"""
  result = (funcName, trResult)

func translateApi*(self: CLangGen, api: PNode): (string, string) =
  case api.kind
  of nkTypeDef:
    result = self.translateType(api)
  of nkProcDef, nkFuncDef, nkMethodDef:
    result = translateProc(api)
  else:
    result = (api.itemName, "Cannot translate Api to C")

method convertEnumToEnumFlag(self: CLangGen, enumBody: string): string =
  let enumBodyLines = enumBody.splitLines
  let itemLines = enumBodyLines[1 ..^ 2]
  # add NONE enum item
  let spaceCount =
    itemLines[0].len - itemLines[0].strip(trailing = false, chars = {' '}).len
  let noneLine = " ".repeat(spaceCount) & "NONE = 0,"
  var flagLines: seq[string] = @[noneLine]
  for i in 0 ..< itemLines.len:
    let enumVal = &"1 << {i}"
    var item = itemLines[i]
    if i == itemLines.len - 1:
      item.add(&" = {enumVal}")
    else:
      item.insert(&" = {enumVal}", item.len - 1)
    flagLines.add(item)
  result = concat(@[enumBodyLines[0]], flagLines, @[enumBodyLines[^1]]).join("\n")

func containsBool(apis: seq[PNode]): bool =
  apis.containsType("bool")

func generateCHeaderContent(
    self: CLangGen, headerName: string, bindingAST: seq[PNode]
): string =
  let headerGuard = headerName.toUpperAscii & "_H"
  let optionalStdBoolH =
    if bindingAST.containsBool:
      &"""

#include <stdbool.h>
"""
    else:
      ""
  var cApis: OrderedTable[string, string]
  for api in bindingAST:
    let (apiId, trApi) = self.translateApi(api)
    cApis[apiId] = trApi
  cApis = self.handleEnumFlags(cApis)
  cApis = collect(initOrderedTable):
    for k, v in cApis.pairs:
      if v != "":
        {k: v}
  result =
    &"""
#ifndef {headerGuard}
#define {headerGuard}
{optionalStdBoolH}
{cApis.values.toseq.join("\n\n")}

#endif /* {headerGuard} */
"""

proc generateCHeader(self: CLangGen, bindingAST: seq[PNode]) =
  let content = self.generateCHeaderContent(moduleName, bindingAST)
  if showVerboseOutput:
    styledEcho fgGreen, "C Header Content:"
    echo content
  let headerFilePath = self.langDir / self.headerFileName
  self.ensureDir()
  headerFilePath.string.writeFile(content)

method realTestDir(self: CLangGen): Path {.base.} =
  testDirPath / "C".Path

method testCompileCode(self: CLangGen): string {.base.} =
  "testCode.c"

method staticLibBuildCmd(self: CLangGen): string {.base.} =
  &"nim c -d:release --noMain:on --app:staticlib --outdir:{self.langDir.string} {self.bindingModuleFile.string}"

method dynamicLibBuildCmd(self: CLangGen): string {.base.} =
  &"nim c -d:release --noMain:on --app:lib --outdir:{self.langDir.string} {self.bindingModuleFile.string}"

method compileTestCodeStaticLibCmd(
    self: CLangGen, staticLibName: string
): string {.base.} =
  &"gcc {string self.realTestDir / self.testCompileCode.Path} {string self.realTestDir / staticLibName.Path}"

method compileTestCodeDynamicLibCmd(
    self: CLangGen, dynamicLibName: string
): string {.base.} =
  &"gcc {string self.realTestDir / self.testCompileCode.Path} {string self.realTestDir / dynamicLibName.Path}"

method getReadMeContent*(self: CLangGen): string =
  let common = procCall self.BaseLangGen.getReadMeContent()
  let staticLibName =
    if defined(windows):
      "$#.lib".format(moduleName)
    else:
      "lib$#.a".format(moduleName)
  let dynamicLibName =
    if defined(windows):
      "$#.dll".format(moduleName)
    elif defined(macosx):
      "lib$#.dylib".format(moduleName)
    else:
      "lib$#.so".format(moduleName)
  let wincpdll =
    if defined(windows):
      &"""
Copy the dll to pwd

    cp {string self.realTestDir / dynamicLibName.Path} .
"""
    else:
      ""
  let outBinExec = if defined(windows): ".\\a.exe" else: "./a.out"
  result =
    &"""
{common}

#### Static Library

    {self.staticLibBuildCmd}

#### Dynamic Library

    {self.dynamicLibBuildCmd}

### Usage
Copy the header file and lib binary to your project.

    cp {string self.langDir / self.headerFileName} {self.realTestDir.string}

#### For static lib:

    cp {string self.langDir / staticLibName.Path} {self.realTestDir.string}

Include the header and compile your code & link to library. In the following example, `{self.testCompileCode}` is the code to compile.

    {self.compileTestCodeStaticLibCmd(staticLibName)}

Then [run & verify](#run--verify).

#### For dynamic lib:

    cp {string self.langDir / dynamicLibName.Path} {self.realTestDir.string}

Include the header and compile your code & link to library. In the following example, `{self.testCompileCode}` is the code to compile.

    {self.compileTestCodeDynamicLibCmd(dynamicLibName)}

{wincpdll}
Then [run & verify](#run--verify).

#### Usage with CMake
Update your CMakeLists.txt appropriately (don't replace existing `add_executable` or `target_link_libraries`):

    target_link_libraries(${{PROJECT_NAME}} ${{CMAKE_CURRENT_LIST_DIR}}/{staticLibName})

    add_executable(${{PROJECT_NAME}} {self.headerFileName.string})

##### Run & verify:

    {outBinExec}
"""
  if showVerboseOutput:
    styledEcho fgBlue, "ReadMe for C:"
    echo result

method generateBinding*(self: CLangGen, bindingAST: seq[PNode]) =
  ## Generates binding & documentation for C
  self.generateCHeader(bindingAST)
  self.generateReadMe()
