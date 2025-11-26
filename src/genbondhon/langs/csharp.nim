# SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
#
# SPDX-License-Identifier: MIT

import
  std/[math, options, paths, sequtils, strformat, strutils, sugar, tables, terminal]
import compiler/ast
import base
import ../[convertutil, currentconfig, util]

type CSharpLangGen = ref object of BaseLangGen
  wrapperFileName: Path
  dllName: string
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

func wrapperFuncName(funcName: string): string =
  funcName.capitalizeAscii & "Val"

method translateEnum(self: CSharpLangGen, node: PNode): (string, string) =
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

  let trResult =
    &"""
        public enum {enumName}: {enumDataType}
        {{
            {enumVals.join(",\n            ")}
        }}"""
  result = (enumName, trResult)

func translateProc(self: CSharpLangGen, node: PNode): (string, string) =
  var shouldWrap = false
  let funcName = node.itemName
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
  var trResult =
    &"""
        [DllImport("{self.dllName}", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Unicode, EntryPoint = "{funcName}")]
        {accessor} static extern {externProc};"""
  if retType.replaceType == "string":
    trResult =
      &"""
        [return: MarshalAs(UnmanagedType.LPUTF8Str)]
{trResult}"""
  elif retType.replaceType in ["bool", "char"]: # C char is 1 byte
    trResult =
      &"""
        [return: MarshalAs(UnmanagedType.U1)]
{trResult}"""
  if shouldWrap:
    trResult =
      &"""
        public static {trProc} {{
{retBody}
        }}

{trResult}"""
  result = (funcName, trResult)

func translateApi(self: CSharpLangGen, api: PNode): (string, string) =
  case api.kind
  of nkTypeDef:
    result = self.translateType(api)
  of nkProcDef, nkFuncDef, nkMethodDef:
    result = self.translateProc(api)
  else:
    result = (api.itemName, "Cannot translate Api to C#")

method convertEnumToEnumFlag(self: CSharpLangGen, enumBody: string): string =
  let enumBodyLines = enumBody.splitLines
  let itemLines = enumBodyLines[2 ..^ 2]
  # add Flags attribute
  var spaceCount =
    enumBodyLines[0].len - enumBodyLines[0].strip(trailing = false, chars = {' '}).len
  let flagAttributeLine = " ".repeat(spaceCount) & "[Flags]"
  # add NONE enum item
  spaceCount =
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
  result = concat(
      @[flagAttributeLine, enumBodyLines[0], enumBodyLines[1]],
      flagLines,
      @[enumBodyLines[^1]],
    )
    .join("\n")

func generateDllWrapperContent(
    self: CSharpLangGen, bindingAST: seq[PNode], modName: string
): string =
  var cSharpApis: OrderedTable[string, string]
  for api in bindingAST:
    let (apiId, trApi) = self.translateApi(api)
    cSharpApis[apiId] = trApi
  cSharpApis = self.handleEnumFlags(cSharpApis)
  cSharpApis = collect(initOrderedTable):
    for k, v in cSharpApis.pairs:
      if v != "":
        {k: v}
  result =
    &"""
using System.Runtime.InteropServices;

namespace {modName.capitalizeAscii}Lib
{{
    public class {modName.capitalizeAscii}
    {{
{cSharpApis.values.toseq.join("\n\n")}
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
