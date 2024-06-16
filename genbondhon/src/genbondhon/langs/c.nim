# SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
#
# SPDX-License-Identifier: MIT

import std/[options, paths, sequtils, strformat, strutils, tables, terminal]
import compiler/ast
import base
import ../[convertutil, currentconfig, util]

type CLangGen = ref object of BaseLangGen
  headerFileName: Path

proc newCLangGen*(bindingDir: Path): CLangGen =
  result = CLangGen(
    langDir: bindingDir / "C".Path, headerFileName: moduleName.Path.addFileExt("h")
  )
  initBaseLangGen(result)

func replaceType(nimCType: string): string =
  nimCompatToCTypeTbl.getOrDefault(nimCType, nimCType)

proc translateProc(node: PNode): string =
  let funcName = procName(node)
  let paramNode = procParamNode(node)
  var retType = "void"
  var trParamList = newSeq[string]()
  if paramNode.isSome:
    let formalParamNode = paramNode.get()
    for i in 1 ..< formalParamNode.safeLen:
      let paramName = formalParamNode[i][0].ident.s
      let paramType = formalParamNode[i][1].ident.s
      let trParam = &"{paramType.replaceType} {paramName}"
      trParamList.add(trParam)
    if formalParamNode[0].kind != nkEmpty:
      retType = formalParamNode[0].ident.s
  result =
    &"""
{retType.replaceType} {funcName}({trParamList.join(", ")});"""

proc translateApi(api: PNode): string =
  case api.kind
  of nkProcDef, nkFuncDef, nkMethodDef:
    result = translateProc(api)
  else:
    result = "Cannot translate Api to C"

func containsBool(apis: seq[PNode]): bool =
  # for api in apis:
  #   debugEcho api.procName
  #   if api.procParamNode.isSome:
  #     debugEcho api.procName & " has paramNode"
  #     if api.procParamNode.get()[0].kind != nkEmpty:
  #       if api.procParamNode.get[0].ident.s == "bool":
  #         return true
  #   else:
  #     debugEcho api.procName & ": no paramNode"
  # return false
  apis.anyIt(
    if it.procParamNode.isSome and it.procParamNode.get[0].kind != nkEmpty and
        it.procParamNode.get[0].ident.s == "bool": true else: false
  )

proc generateCHeaderContent(
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
  var cApis = newSeq[string]()
  for api in bindingAST:
    let trApi = translateApi(api)
    cApis.add(trApi)
  result =
    &"""
#ifndef {headerGuard}
#define {headerGuard}
{optionalStdBoolH}
{cApis.join("\n\n")}

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

method getReadMeContent(self: CLangGen): string =
  let common = procCall self.BaseLangGen.getReadMeContent()
  let realTestDir = testDirPath / "C".Path
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
  let testCompileCode = "testCode.c"
  let wincpdll =
    if defined(windows):
      &"""
Copy the dll to pwd

    cp {string realTestDir.Path / dynamicLibName.Path} .
"""
    else:
      ""
  let outBinExec = if defined(windows): ".\\a.exe" else: "./a.out"
  result =
    &"""
{common}

#### Static Library

    nim c -d:release --noMain:on --app:staticlib --outdir:{self.langDir.string} {self.bindingModuleFile.string}

#### Dynamic Library

    nim c -d:release --noMain:on --app:lib --outdir:{self.langDir.string} {self.bindingModuleFile.string}

### Usage
Copy the lib binary and header file to your project.

    cp {string self.langDir / self.headerFileName} {realTestDir.string}

#### For static lib:

    cp {string self.langDir / staticLibName.Path} {realTestDir.string}

Include the header and compile your code & link to library. In the following example, `{testCompileCode}` is the code to compile.

    gcc {string realTestDir / testCompileCode.Path} {string realTestDir / staticLibName.Path}

#### For dynamic lib:

    cp {string self.langDir / dynamicLibName.Path} {realTestDir.string}

Include the header and compile your code & link to library. In the following example, `{testCompileCode}` is the code to compile.

    gcc {string realTestDir / testCompileCode.Path} {string realTestDir / dynamicLibName.Path}

{wincpdll}
Then run & verify:

    {outBinExec}
"""
  if showVerboseOutput:
    styledEcho fgBlue, "ReadMe for C:"
    echo result

method generateBinding*(self: CLangGen, bindingAST: seq[PNode]) =
  self.generateCHeader(bindingAST)
  self.generateReadMe()
