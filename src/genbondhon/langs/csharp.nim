# SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
#
# SPDX-License-Identifier: MIT

import std/[options, paths, strformat, strutils, tables, terminal]
import compiler/ast
import base
import ../[convertutil, currentconfig, util]

type CSharpLangGen = ref object of BaseLangGen
  wrapperFileName: Path
  dllName: string

proc newCSharpLangGen*(bindingDir: Path): CSharpLangGen =
  ## `CSharpLangGen` constructor
  result = CSharpLangGen(
    langDir: bindingDir / "C#".Path,
    wrapperFileName: moduleName.Path.addFileExt("cs"),
    dllName: moduleName & ".dll",
  )
  initBaseLangGen(result)

func replaceType(nimCType: string): string =
  ## Replaces Nim Compat Types to C# Types
  nimCompatToCSharpTypeTbl.getOrDefault(nimCType, nimCType)

method translateEnum(self: CSharpLangGen, node: PNode): string =
  let enumName = node.itemName
  let enumValsParent = node[2]
  var enumVals: seq[string]
  for i in 1 ..< enumValsParent.safeLen:
    let enumVal = enumValsParent[i].ident.s
    let val =
      &"""
{enumVal.capitalizeAscii}"""
    enumVals.add(val)
  result =
    &"""
        public enum {enumName}
        {{
            {enumVals.join(",\n            ")}
        }}"""

func translateProc(node: PNode, dllName: string): string =
  let funcName = procName(node)
  let paramNode = procParamNode(node)
  var retType = "void"
  var trParamList: seq[string]
  if paramNode.isSome:
    let formalParamNode = paramNode.get()
    for i in 1 ..< formalParamNode.safeLen:
      let paramName = formalParamNode[i].paramName
      let paramType = formalParamNode[i].paramType
      var trParam = &"{paramType.replaceType} {paramName}"
      if paramType.replaceType == "string":
        trParam = &"[MarshalAs(UnmanagedType.LPUTF8Str)] {trParam}"
      elif paramType.replaceType == "bool":
        trParam = &"[MarshalAs(UnmanagedType.U1)] {trParam}"
      trParamList.add(trParam)
    if formalParamNode[0].kind != nkEmpty:
      retType = formalParamNode[0].ident.s
  result =
    &"""
        [DllImport("{dllName}", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Unicode, EntryPoint = "{funcName}")]
        public static extern {retType.replaceType} {funcName.capitalizeAscii}({trParamList.join(", ")});"""
  if retType.replaceType == "string":
    result =
      &"""
        [return: MarshalAs(UnmanagedType.LPUTF8Str)]
{result}"""
  elif retType.replaceType in ["bool", "char"]: # C char is 1 byte
    result =
      &"""
        [return: MarshalAs(UnmanagedType.U1)]
{result}"""

func translateApi(self: CSharpLangGen, api: PNode): string =
  case api.kind
  of nkTypeDef:
    result = self.translateType(api)
  of nkProcDef, nkFuncDef, nkMethodDef:
    result = translateProc(api, self.dllName)
  else:
    result = "Cannot translate Api to C#"

func generateDllWrapperContent(
    self: CSharpLangGen, bindingAST: seq[PNode], modName: string
): string =
  var cSharpApis: seq[string]
  for api in bindingAST:
    let trApi = self.translateApi(api)
    cSharpApis.add(trApi)
  result =
    &"""
using System.Runtime.InteropServices;

namespace {modName.capitalizeAscii}Lib
{{
    public class {modName.capitalizeAscii}
    {{
{cSharpApis.join("\n\n")}
    }}
}}
"""

proc generateCSharpDllWrapper(self: CSharpLangGen, bindingAST: seq[PNode]) =
  let content = self.generateDllWrapperContent(bindingAST, moduleName)
  if showVerboseOutput:
    styledEcho fgGreen, "CSharp Dll Wrapper Content:"
    echo content
  let wrapperFilePath = self.langDir / self.wrapperFileName
  self.ensureDir()
  wrapperFilePath.string.writeFile(content)

method getReadMeContent(self: CSharpLangGen): string =
  let common = procCall self.BaseLangGen.getReadMeContent()
  let realTestDir = testDirPath / "C#".Path
  result =
    &"""
{common}

### Note
This binding is tested only on Windows.

#### Static Library
Not supported

#### Dynamic Library

    nim c --cc:vcc -d:release --noMain:on --app:lib --outdir:{self.langDir.string} {self.bindingModuleFile.string}

### Usage
Copy the wrapper file and lib binary to your project.

    cp {string self.langDir / self.wrapperFileName} {realTestDir.string}
    cp {string self.langDir / self.dllName.Path} {realTestDir.string}

In Solution Explorer, right click on Project File > Add > Existing Item > Change filter and select the Dll.

Select the Dll file in Solution Explorer, Change Settings of Copy to Output Directory to Copy If Newer.

Add the wrapper file as an existing item to the project.

Use the wrapper file in your code and call wrapper APIs.
"""

method generateBinding*(self: CSharpLangGen, bindingAST: seq[PNode]) =
  ## Generates binding & documentation for C#
  self.generateCSharpDllWrapper(bindingAST)
  self.generateReadMe()
