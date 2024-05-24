# SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
#
# SPDX-License-Identifier: MIT

import std/[options, strformat, strutils, tables, terminal]
import compiler/ast
import convertutil, currentconfig, util

func replaceType(nimType: string): string =
  nimToCompatTypeTbl[nimType]

func convertRetType(code: string, nimType: string): string =
  convertNimToCompatType(nimType, code)

proc translateProc(node: PNode): string =
  let procName = procName(node)
  let paramNode = procParamNode(node)
  if paramNode.isNone:
    styledEcho fgRed, "Error!!! FormalParamNode missing!"
  let formalParamNode = paramNode.get()
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
  let procCall = &"{moduleName}.{procName}()"
  let retBody =
    if retType == "":
      procCall
    else:
      &"return {procCall.convertRetType(retType)}"
  result =
    &"""
proc {procName}*(){retTypePart} {{.raises:[], exportc, cdecl, dynlib.}} =
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
