# SPDX-FileCopyrightText: 2025 Rifat Hasan <atunutemp1@gmail.com>
#
# SPDX-License-Identifier: MIT

import std/[options, paths, sequtils, strformat, strutils, sugar, tables, terminal]
import base
import compiler/ast
import ../[convertutil, currentconfig, store, util]

type TypeScriptLangGen = ref object of BaseLangGen
  declarationFileName: Path

proc newTypeScriptLangGen*(bindingDir: Path): TypeScriptLangGen =
  ## `TypeScriptLangGen` constructor
  result = TypeScriptLangGen(
    langDir: bindingDir / "ts".Path,
    declarationFileName: moduleName.Path.addFileExt("d.ts"),
  )
  initBaseLangGen(result)

func replaceType(nimCType: string): string =
  ## Replaces Nim Compat Types to TypeScript Types
  nimCompatToTypeScriptTypeTbl.getOrDefault(nimCType, nimCType)

method translateEnum(self: TypeScriptLangGen, node: PNode): (string, string) =
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
    val = &"{val},"
    enumVals.add(val)
  let trResult =
    &"""
export enum {enumName} {{
  {enumVals.join("\n  ")}
}}"""
  result = (enumName, trResult)

func translateProc(
    node: PNode, flagLookupTbl: Table[string, Table[string, string]]
): (string, string) =
  let funcName = node.itemName
  if funcName == "NimMain":
    return (funcName, "")
  let hasFlagEnum = flagLookupTbl.contains(funcName)
  let paramNode = procParamNode(node)
  var retType = ""
  var trParamList: seq[string]
  if paramNode.isSome:
    let formalParamNode = paramNode.get()
    for i in 1 ..< formalParamNode.safeLen:
      let paramName = formalParamNode[i].paramName
      let paramType = formalParamNode[i].paramType
      let origParamType =
        if hasFlagEnum:
          checkRestoreFlagEnumType(paramName, paramType, flagLookupTbl[funcName])
        else:
          paramType
      let trParam = &"{paramName}: {origParamType.replaceType}"
      trParamList.add(trParam)
    if formalParamNode[0].kind != nkEmpty:
      retType = formalParamNode[0].ident.s
  let retTypePart =
    if retType == "":
      ""
    else:
      &": {retType.replaceType}"
  let trResult =
    &"""
export function {funcName}({trParamList.join(", ")}){retTypePart};"""
  result = (funcName, trResult)

func translateApi(
    self: TypeScriptLangGen, api: PNode, flagTbl: Table[string, Table[string, string]]
): (string, string) =
  case api.kind
  of nkTypeDef:
    result = self.translateType(api)
  of nkProcDef, nkFuncDef, nkMethodDef:
    result = translateProc(api, flagTbl)
  else:
    result = (&"fail-{$api.kind}", "Cannot translate Api to TypeScript")

method convertEnumToEnumFlag(self: TypeScriptLangGen, enumBody: string): string =
  let enumBodyLines = enumBody.splitLines
  let itemLines = enumBodyLines[1 ..^ 2]
  # add NONE enum item
  let spaceCount =
    itemLines[0].len - itemLines[0].strip(trailing = false, chars = {' '}).len
  let noneLine = " ".repeat(spaceCount) & "None = 0,"
  var flagLines: seq[string] = @[noneLine]
  for i in 0 ..< itemLines.len:
    let enumVal = &"1 << {i}"
    var item = itemLines[i]
    item.insert(&" = {enumVal}", item.len - 1)
    flagLines.add(item)
  result = concat(@[enumBodyLines[0]], flagLines, @[enumBodyLines[^1]]).join("\n")

func generateTypeScriptWrapperContent(
    self: TypeScriptLangGen,
    bindingAST: seq[PNode],
    flagLookupTbl: Table[string, Table[string, string]],
): string =
  var typescriptApis: OrderedTable[string, string]
  for api in bindingAST:
    let (apiId, trApi) = self.translateApi(api, flagLookupTbl)
    typescriptApis[apiId] = trApi
  typescriptApis = self.handleEnumFlags(typescriptApis)
  typescriptApis = collect(initOrderedTable):
    for k, v in typescriptApis.pairs:
      if v != "":
        {k: v}
  result =
    &"""
{typescriptApis.values.toseq.join("\n\n")}
"""

proc generateTypeScriptDeclaration(self: TypeScriptLangGen, bindingAST: seq[PNode]) =
  let content =
    self.generateTypeScriptWrapperContent(bindingAST, flagEnumRevrsLookupTbl)
  if showVerboseOutput:
    styledEcho fgGreen, "TypeScript Declaration file content:"
    echo content
  let declarationFilePath = self.langDir / self.declarationFileName
  self.ensureDir()
  declarationFilePath.string.writeFile(content)

method getReadMeContent(self: TypeScriptLangGen): string =
  let common = procCall self.BaseLangGen.getReadMeContent()
  result =
    &"""
{common}
Use the `js` backend to generate the library.

    nim js -d:release --noMain:on --app:lib --out:{string self.langDir / moduleName.Path}.mjs {self.bindingModuleFile.string}

Modify `tsconfig.json`.
The module value should be set to a compatible ESModule (e.g. ESNext),
and allowJS should be set to true. Check if extends already did, if not, add your own.

    {{
      ...
      "compilerOptions": {{
        ...
        "module": "ESNext",
        ...
        "allowJs": true,
        ...
      }},
      ...
    }}

Now copy `{moduleName}.d.ts` and `{moduleName}.mjs` to your project.
Put them in your preferred location and import without extension.
e.g. If in the same directory, then use `import {{...}} from ./{moduleName}`.
"""

method generateBinding*(self: TypeScriptLangGen, bindingAST: seq[PNode]) =
  ## Generates binding & documentation for TypeScript
  self.generateTypeScriptDeclaration(bindingAST)
  self.generateReadMe()
