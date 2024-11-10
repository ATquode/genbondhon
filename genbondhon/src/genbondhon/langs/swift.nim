# SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
#
# SPDX-License-Identifier: MIT

import std/[options, os, paths, strformat, strutils, tables, terminal]
import compiler/ast
import base
import ../[convertutil, currentconfig, util]

type SwiftLangGen = ref object of BaseLangGen
  cModuleName: string
  cLangDir: Path
  wrapperFileName: Path
  headerFileName: string
  moduleMapName: Path

proc newSwiftLangGen*(bindingDir: Path): SwiftLangGen =
  ## `SwiftLangGen` constructor
  result = SwiftLangGen(
    langDir: bindingDir / "Swift".Path,
    cModuleName: "C" & moduleName.capitalizeAscii,
    cLangDir: bindingDir / "C".Path,
    wrapperFileName: moduleName.Path.addFileExt("swift"),
    headerFileName: moduleName.Path.addFileExt("h").string,
    moduleMapName: "module".Path.addFileExt("modulemap"),
  )
  initBaseLangGen(result)

func replaceType(nimSwiftType: string): string =
  ## Replaces Nim Compat Types to Swift Types & vice versa
  nimCompatAndSwiftTypeTbl.getOrDefault(nimSwiftType, nimSwiftType)

func convertType(code: string, origType: string): string =
  convertNimAndSwiftType(origType, code)

func swiftCModuleDir(self: SwiftLangGen): Path =
  self.langDir / self.cModuleName.Path

proc copyCHeader(self: SwiftLangGen) =
  ## Copies C Header from C output
  let cDirHeaderPath = self.cLangDir / self.headerFileName.Path
  self.ensureDir(self.swiftCModuleDir)
  cDirHeaderPath.string.copyFileToDir(self.swiftCModuleDir.string)

func generateModuleMapContent(self: SwiftLangGen, libName: string): string =
  result =
    &"""
module {self.cModuleName} {{
  header "{self.headerFileName}"
  link "{libName}"
  export *
}}
"""

proc generateModuleMap(self: SwiftLangGen) =
  let content = self.generateModuleMapContent(moduleName)
  if showVerboseOutput:
    styledEcho fgGreen, "Swift C modulemap content:"
    echo content
  let moduleMapFilePath = self.swiftCModuleDir / self.moduleMapName
  moduleMapFilePath.string.writeFile(content)

func translateProc(node: PNode, libName: string): string =
  let funcName = procName(node)
  let paramNode = procParamNode(node)
  var retType = ""
  var trParamList, callableParamList: seq[string]
  if paramNode.isSome:
    let formalParamNode = paramNode.get()
    for i in 1 ..< formalParamNode.safeLen:
      let paramName = formalParamNode[i].paramName
      let paramType = formalParamNode[i].paramType
      let trParam = &"{paramName}: {paramType.replaceType}"
      trParamList.add(trParam)
      let callableParam = paramName.convertType(paramType.replaceType)
      callableParamList.add(callableParam)
    if formalParamNode[0].kind != nkEmpty:
      retType = formalParamNode[0].ident.s
  let retTypePart =
    if retType == "":
      ""
    else:
      &" -> {retType.replaceType}"
  let procCallStmt = &"""{libName}.{funcName}({callableParamList.join(", ")})"""
  var retBody =
    if retType == "":
      procCallStmt
    else:
      &"return {procCallStmt.convertType(retType)}"
  if retType.replaceType == "String":
    retBody =
      &"""let temp = {procCallStmt}
    guard let data = temp else {{
        print("Error!! Failed to get string from {funcName}")
        return "Failed to get string from {funcName}"
    }}
    return {"data".convertType(retType)}"""
  result =
    &"""
func {funcName}({trParamList.join(", ")}){retTypePart} {{
    {retBody}
}}"""

func translateApi(api: PNode, libName: string): string =
  case api.kind
  of nkProcDef, nkFuncDef, nkMethodDef:
    result = translateProc(api, libName)
  else:
    result = "Cannot translate Api to Swift"

func generateSwiftWrapperContent(
    bindingAST: seq[PNode], modName: string, cModuleName: string
): string =
  var swiftApis: seq[string]
  for api in bindingAST:
    let trApi = translateApi(api, cModuleName)
    swiftApis.add(trApi)
  result =
    &"""
import {cModuleName}

{swiftApis.join("\n\n")}
"""

proc generateSwiftWrapper(self: SwiftLangGen, bindingAST: seq[PNode]) =
  let content = generateSwiftWrapperContent(bindingAST, moduleName, self.cModuleName)
  if showVerboseOutput:
    styledEcho fgGreen, "Swift Wrapper Content:"
    echo content
  let wrapperFilePath = self.swiftCModuleDir / self.wrapperFileName
  wrapperFilePath.string.writeFile(content)

method getReadMeContent(self: SwiftLangGen): string =
  let common = procCall self.BaseLangGen.getReadMeContent()
  let bindingMacosPath = self.langDir / "macOS".Path
  let realTestDir = testDirPath / "Swift".Path
  let realTestDirMac = realTestDir / "macOS".Path
  let testDirSwiftModule = realTestDirMac / self.cModuleName.Path
  let staticLibName = "lib$#.a".format(moduleName).Path
  result =
    &"""
{common}

### Note
This generated module can be used in both macOS and iOS.

### macOS
#### Static Library

    nim c -d:release --noMain:on --app:staticlib --outdir:{bindingMacosPath.string} {self.bindingModuleFile.string}

#### Dynamic Library
Not supported

#### Usage
Copy the module and lib binary to your project. Put the lib binary inside module directory.

    mkdir {realTestDirMac.string}
    cp -r {self.swiftCModuleDir.string} {testDirSwiftModule.string}
    cp {string bindingMacosPath / staticLibName} {testDirSwiftModule.string}

Then see [Setup Xcode](#setup-xcode)

### Setup Xcode
In Xcode, add the module directory's parent to `Swift Compiler - Search Paths` > `Import Paths`.
Do not include the module directory itself in the path.

For example, let's say you have put the module directory in {string realTestDirMac / "CommandLineApplication1/CommandLineApplication1".Path / self.cModuleName.Path},
then you should add `$(PROJECT_DIR)/CommandLineApplication1` to the search path > import path.
$(PROJECT_DIR) refers to the directory with .xcproj file.
So the path will be {string realTestDirMac / "CommandLineApplication1/CommandLineApplication1".Path}, the parent directory of {self.cModuleName}.

Then add the path of {staticLibName.string} to `Library Search Paths`,
e.g. {string "$(PROJECT_DIR)/CommandLineApplication1".Path / self.cModuleName.Path},
which will resolve to {string realTestDirMac / "CommandLineApplication1/CommandLineApplication1".Path / self.cModuleName.Path}
"""

method generateBinding*(self: SwiftLangGen, bindingAST: seq[PNode]) =
  ## Generates binding & documentation for Swift
  self.copyCHeader()
  self.generateModuleMap()
  self.generateSwiftWrapper(bindingAST)
  self.generateReadMe()
