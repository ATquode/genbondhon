# SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
#
# SPDX-License-Identifier: MIT

import
  std/[dirs, options, paths, sequtils, strformat, strutils, sugar, tables, terminal]
import compiler/ast
import convertutil, currentconfig, util, langs/base

proc relativeModulePath(): string =
  let relModFilePath = origFile.relativePath(bindingDirPath, '/')
  let relModPath = relModFilePath.changeFileExt("")
  result = relModPath.string

proc generateWrapperFileContent(
    wrappedApis: string, typeDefs, apiNames: seq[string]
): string =
  let modulePath = relativeModulePath()
  let vccCondImport =
    if shouldUseVCCStr:
      &"""

when defined(vcc):
  proc CoTaskMemAlloc(cb: int): cstring {{.cdecl, dynlib: "ole32.dll", importc.}}
"""
    else:
      ""
  let exportedApiNames = &"""{{ {apiNames.join(", ")} }}"""
  let q3 = "\"\"\""
  result =
    &"""
import {modulePath}
{vccCondImport}
{wrappedApis}
when defined(js):
  {{.
    emit: {q3}

{typeDefs.join("\n\n")}

export {exportedApiNames};
{q3}
  .}}
"""

func translateEnum(jsLangGen: BaseLangGen, node: PNode): (BaseLangGen, string) =
  let enumName = node.itemName
  jsLangGen.storeNamedType(enumName, NamedTypeCategory.enumType)
  let enumValsParent = node[2]
  var enumVals: seq[string]
  var incVal = 0
  for i in 1 ..< enumValsParent.safeLen:
    let (enumValName, enumValVal) = enumValsParent[i].enumNameValue
    let enumValValue =
      if enumValVal.isSome:
        enumValVal.unsafeGet
      else:
        if i != 1:
          incVal + 1
        else:
          i - 1
    incVal = enumValValue

    let val =
      &"""
{enumValName.capitalizeAscii}: {enumValValue},"""
    enumVals.add(val)
  let trResult =
    &"""
const {enumName} = {{
  {enumVals.join("\n  ")}
}};"""
  result = (jsLangGen, trResult)

func translateContainer(jsLangGen: BaseLangGen, node: PNode): (BaseLangGen, string) =
  let containerType = node[2][0].ident.s
  let memberType = node[2][1].ident.s
  case containerType
  of "set":
    jsLangGen.ignoreApiList.add(node.itemName)
    if jsLangGen.typeCategory(memberType) == NamedTypeCategory.enumType:
      jsLangGen.flagEnums.add(memberType)
      result = (jsLangGen, "")
    else:
      result = (jsLangGen, "Api not supported: set")
  else:
    result = (jsLangGen, "Cannot translate Api")

func translateType(jsLangGen: BaseLangGen, node: PNode): (BaseLangGen, string) =
  case node.subType
  of nkEnumTy:
    result = jsLangGen.translateEnum(node)
  of nkBracketExpr:
    result = jsLangGen.translateContainer(node)
  else:
    result = (jsLangGen, "Cannot translate Api")

func convertEnumToEnumFlag(enumBody: string): string =
  let enumBodyLines = enumBody.splitLines
  let itemLines = enumBodyLines[1 .. ^2]
  # add NONE enum item
  let spaceCount =
    itemLines[0].len - itemLines[0].strip(trailing = false, chars = {' '}).len
  let noneLine = " ".repeat(spaceCount) & "None: 0,"
  var flagLines: seq[string] = @[noneLine]
  for i in 0 ..< itemLines.len:
    let enumVal = &"1 << {i},"
    var item = itemLines[i]
    item = item[0 .. item.rfind(" ")] & enumVal
    flagLines.add(item)
  result = concat(@[enumBodyLines[0]], flagLines, @[enumBodyLines[^1]]).join("\n")

func handleEnumFlags(
    jsLangGen: BaseLangGen, jsTypes: OrderedTable[string, string]
): OrderedTable[string, string] =
  if jsLangGen.flagEnums.len == 0:
    return jsTypes

  result = jsTypes
  for flagEnum in jsLangGen.flagEnums:
    if flagEnum notin jsTypes:
      # echo &"Error!!! {flagEnum} not found in JS Api keys"
      continue
    let flagEnumBody = result[flagEnum].convertEnumToEnumFlag()
    result[flagEnum] = flagEnumBody

func typeDefinitions(jsBaseLangGen: BaseLangGen, apis: seq[PNode]): seq[string] =
  var jsLangGen = jsBaseLangGen
  var jsTypes: OrderedTable[string, string]
  var typeDefin = ""
  for api in apis:
    let typeName = api.itemName
    case api.kind
    of nkTypeDef:
      (jsLangGen, typeDefin) = jsLangGen.translateType(api)
      jsTypes[typeName] = typeDefin
    else:
      jsTypes[typeName] = "Cannot translate Api"
  jsTypes = jsLangGen.handleEnumFlags(jsTypes)
  jsTypes = collect(initOrderedTable):
    for k, v in jsTypes.pairs:
      if v != "":
        {k: v}
  result = jsTypes.values.toseq

proc generateWrapperFile*(
    wrappedApis: string, wrapperName: string, wrappableAST, unwrappableAST: seq[PNode]
): Path =
  ## Generates wrapper file in `bindingDir` with `wrapperName`.
  ## Returns wrapper file path.
  let fileName = wrapperName.Path.addFileExt("nim")
  if not bindingDirPath.dirExists:
    try:
      bindingDirPath.createDir()
    except:
      let exceptionMsg = getCurrentExceptionMsg()
      styledEcho fgRed,
        "Error: Failed to create binding directory. Reason: ", exceptionMsg
      return
  let filePath = bindingDirPath / fileName
  let nimMainStr = "proc NimMain*() {.raises:[], exportc, cdecl, dynlib, importc.}"
  let wrapperApis =
    &"""
{nimMainStr}

{wrappedApis}"""
  let jsLangGen = BaseLangGen()
  let typeDefs = jsLangGen.typeDefinitions(unwrappableAST)
  let apiNames = concat(unwrappableAST, wrappableAST).map(x => x.itemName).filter(
      x => x notin jsLangGen.ignoreApiList
    )
  let fileContent = generateWrapperFileContent(wrapperApis, typeDefs, apiNames)
  if showVerboseOutput:
    styledEcho fgYellow, "Wrapper File Content:"
    echo fileContent
  filePath.string.writeFile(fileContent)
  return filePath

proc generateBindableModule*(bindingDir: Path, wrapperName: string) =
  let moduleFileName = moduleName.Path.addFileExt("nim")
  let moduleFilePath = bindingDir / moduleFileName
    # assume the directory already exists, because wrapper file has been created.
  let content =
    &"""
include {wrapperName}
"""
  moduleFilePath.string.writeFile(content)
