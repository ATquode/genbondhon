# SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
#
# SPDX-License-Identifier: MIT

import std/[options, strformat, strutils, tables, terminal]
import compiler/ast
import convertutil, currentconfig, util

func replaceType(nimType: string): string =
  nimAndCompatTypeTbl.getOrDefault(nimType, nimType)

func convertType(code: string, origType: string): string =
  convertNimAndCompatType(origType, code)

proc translateProc(node: PNode): string =
  let procName = procName(node)
  let paramNode = procParamNode(node)
  if paramNode.isNone:
    styledEcho fgRed, "Error!!! FormalParamNode missing!"
  let formalParamNode = paramNode.get()
  var trParamList, callableParamList = newSeq[string]()
  for i in 1 ..< formalParamNode.safeLen:
    let paramName = formalParamNode[i][0].ident.s
    let paramType = formalParamNode[i][1].ident.s
    let trParam = &"{paramName}: {paramType.replaceType}"
    trParamList.add(trParam)
    let callableParam = &"{paramName.convertType(paramType.replaceType)}"
    callableParamList.add(callableParam)
  let retType =
    if formalParamNode[0].kind != nkEmpty:
      formalParamNode[0].ident.s
    else:
      ""
  let retTypePart =
    if retType == "":
      ""
    else:
      &""": {retType.replaceType}"""
  let procCall = &"""{moduleName}.{procName}({callableParamList.join(", ")})"""
  let retBody =
    if retType == "":
      procCall
    else:
      &"return {procCall.convertType(retType)}"
  result =
    &"""
proc {procName}*({trParamList.join(", ")}){retTypePart} {{.raises:[], exportc, cdecl, dynlib.}} =
  {retBody}
"""

proc wrapApi(api: PNode): string =
  case api.kind
  of nkProcDef, nkFuncDef, nkMethodDef:
    result = translateProc(api)
  else:
    result = "Cannot wrap api"

proc generateWrapperContent(publicAST: seq[PNode]): string =
  var trApis = newSeq[string]()
  for api in publicAST:
    let wrappedApi = wrapApi(api)
    trApis.add(wrappedApi)
  result =
    &"""
{trApis.join("\n\n")}
"""

proc translateToCompatibleWrapperApi*(publicAST: seq[PNode]): string =
  let apiContent = generateWrapperContent(publicAST)
  if showVerboseOutput:
    styledEcho fgYellow, "Wrapped Apis:"
    echo apiContent
  return apiContent
