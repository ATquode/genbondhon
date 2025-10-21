# SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
#
# SPDX-License-Identifier: MIT

import std/[math, options, paths, strformat, strutils, tables, terminal]
import compiler/ast
import base
import ../[convertutil, currentconfig, util]

type CSharpLangGen = ref object of BaseLangGen
  wrapperFileName: Path
  dllName: string
  namedTypes: Table[string, NamedTypeCategory]
  enumDataTypes: Table[string, string]

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

proc storeNamedType(
    self: CSharpLangGen, typeName: string, typeCategory: NamedTypeCategory
) =
  if typeName in self.namedTypes:
    return
  self.namedTypes[typeName] = typeCategory

func typeCategory(self: CSharpLangGen, typeName: string): NamedTypeCategory =
  self.namedTypes.getOrDefault(typeName, NamedTypeCategory.noneType)

func wrapperFuncName(funcName: string): string =
  funcName.capitalizeAscii & "Val"

method translateEnum(self: CSharpLangGen, node: PNode): string =
  let enumName = node.itemName
  self.storeNamedType(enumName, NamedTypeCategory.enumType)
  let enumValsParent = node[2]
  var enumVals: seq[string]
  var maxEnumVal = 0
  for i in 1 ..< enumValsParent.safeLen:
    let (enumValName, enumValVal) = enumValsParent[i].enumNameValue
    if enumValVal.get(0) > maxEnumVal:
      maxEnumVal = enumValVal.get(0)
    var val =
      &"""
{enumValName.capitalizeAscii}"""
    if enumValVal.isSome:
      val = &"{val} = {enumValVal.unsafeGet}"
    enumVals.add(val)

  var enumDataType = "byte" # For upto value 255
  if maxEnumVal > 2 ^ 32 - 1:
    enumDataType = "ulong"
  elif maxEnumVal > 2 ^ 16 - 1:
    enumDataType = "uint"
  elif maxEnumVal > 255:
    enumDataType = "ushort"

  self.enumDataTypes[enumName] = enumDataType

  result =
    &"""
        public enum {enumName}: {enumDataType}
        {{
            {enumVals.join(",\n            ")}
        }}"""

func translateProc(self: CSharpLangGen, node: PNode): string =
  var shouldWrap = false
  let funcName = procName(node)
  let paramNode = procParamNode(node)
  var retType = "void"
  var trParamList, wrParamList, callableParamList: seq[string]
  var marshalledIndexList: seq[int]
  if paramNode.isSome:
    let formalParamNode = paramNode.get()
    for i in 1 ..< formalParamNode.safeLen:
      let paramName = formalParamNode[i].paramName
      let paramType = formalParamNode[i].paramType
      var trParam = &"{paramType.replaceType} {paramName}"
      var callableParam = paramName
      if self.typeCategory(paramType) == NamedTypeCategory.enumType:
        shouldWrap = true
        if wrParamList.len == 0:
          wrParamList = trParamList
        let wrapType = self.enumDataTypes[paramType]
        let wrParam = &"{wrapType} {paramName}"
        wrParamList.add(wrParam)
        callableParam = &"({wrapType}){paramName}"
      elif shouldWrap:
        let wrParam = trParam
        wrParamList.add(wrParam)
      if paramType.replaceType == "string":
        trParam = &"[MarshalAs(UnmanagedType.LPUTF8Str)] {trParam}"
        marshalledIndexList.add(i - 1)
      elif paramType.replaceType == "bool":
        trParam = &"[MarshalAs(UnmanagedType.U1)] {trParam}"
        marshalledIndexList.add(i - 1)
      trParamList.add(trParam)
      callableParamList.add(callableParam)
    if shouldWrap:
      for i in marshalledIndexList:
        let marshalPartEnd = trParamList[i].find("] ")
        let marshalPart = trParamList[i][0 .. marshalPartEnd]
        let nonMarshalPart = trParamList[i][marshalPartEnd + 2 ..^ 1]
        trParamList[i] = nonMarshalPart
        wrParamList[i] = &"{marshalPart} {nonMarshalPart}"
    if formalParamNode[0].kind != nkEmpty:
      retType = formalParamNode[0].ident.s
  var wrRetType = retType.replaceType
  if self.typeCategory(retType) == NamedTypeCategory.enumType:
    shouldWrap = true
    if wrParamList.len == 0:
      wrParamList = trParamList
      for i in marshalledIndexList:
        let marshalPartEnd = trParamList[i].find("] ")
        let nonMarshalPart = trParamList[i][marshalPartEnd + 2 ..^ 1]
        trParamList[i] = nonMarshalPart
    wrRetType = self.enumDataTypes[retType]
  let trProc =
    &"""{retType.replaceType} {funcName.capitalizeAscii}({trParamList.join(", ")})"""
  let wrProc = &"""{wrRetType} {funcName.wrapperFuncName}({wrParamList.join(", ")})"""
  let procCallStmt = &"""{funcName.wrapperFuncName}({callableParamList.join(", ")})"""
  let retBody =
    if wrRetType == "void":
      &"""
            {procCallStmt};"""
    else:
      &"""
            var data = {procCallStmt};
            return ({retType})data;"""
  let externProc = if shouldWrap: wrProc else: trProc
  let accessor = if shouldWrap: "private" else: "public"
  result =
    &"""
        [DllImport("{self.dllName}", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Unicode, EntryPoint = "{funcName}")]
        {accessor} static extern {externProc};"""
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
  if shouldWrap:
    result =
      &"""
        public static {trProc} {{
{retBody}
        }}

{result}"""

func translateApi(self: CSharpLangGen, api: PNode): string =
  case api.kind
  of nkTypeDef:
    result = self.translateType(api)
  of nkProcDef, nkFuncDef, nkMethodDef:
    result = self.translateProc(api)
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
