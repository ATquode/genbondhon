# SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
#
# SPDX-License-Identifier: MIT

import std/[dirs, options, paths, sequtils, strformat, strutils, sugar, terminal]
import compiler/ast
import currentconfig, util

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

{typeDefs.join("\n")}

export {exportedApiNames};
{q3}
  .}}
"""

func translateEnum(node: PNode): string =
  let enumName = node.itemName
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
  result =
    &"""
const {enumName} = {{
  {enumVals.join("\n  ")}
}};
"""

func translateType(node: PNode): string =
  case node.subType
  of nkEnumTy:
    result = translateEnum(node)
  else:
    result = "Cannot translate Api"

func typeDefinitions(apis: seq[PNode]): seq[string] =
  for api in apis:
    case api.kind
    of nkTypeDef:
      let typeDefin = translateType(api)
      result.add(typeDefin)
    else:
      result.add("Cannot translate Api")

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
  let typeDefs = unwrappableAST.typeDefinitions
  let apiNames = concat(unwrappableAST, wrappableAST).map(x => x.itemName)
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
