# SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
#
# SPDX-License-Identifier: MIT

import std/[options, strformat, strutils, tables, terminal]
import compiler/[ast, astalgo]
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
    let paramName = formalParamNode[i].paramName
    let paramType = formalParamNode[i].paramType
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
  let procCallStmt = &"""{moduleName}.{procName}({callableParamList.join(", ")})"""
  var retBody =
    if retType == "":
      procCallStmt
    else:
      &"return {procCallStmt.convertType(retType)}"
  if shouldUseVCCStr and retType == "string":
    retBody =
      &"""when defined(vcc):
    let nimstr = {procCallStmt}
    let cstr = CoTaskMemAlloc(nimstr.len + 1)
    {{.emit: ["strcpy(", cstr, ", ", nimstr.cstring, ");"].}}
    return cstr
  else:
    {retBody}"""
  result =
    &"""
proc {procName}*({trParamList.join(", ")}){retTypePart} {{.raises:[], exportc, cdecl, dynlib.}} =
  {retBody}"""

proc wrapApi(api: PNode): string =
  case api.kind
  of nkProcDef, nkFuncDef, nkMethodDef:
    result = translateProc(api)
  else:
    result = "Cannot wrap api"

proc generateWrapperApi(wrappableAST: seq[PNode]): string =
  var trApis = newSeq[string]()
  for api in wrappableAST:
    let wrappedApi = wrapApi(api)
    trApis.add(wrappedApi)
  result =
    &"""
{trApis.join("\n\n")}
"""

proc separateWrappableAST(publicAST: seq[PNode]): (seq[PNode], seq[PNode]) =
  ## separate public AST into wrappable and unwrappable ASTs
  var wrappableAST, unwrappableAST: seq[PNode]
  for node in publicAST:
    case node.kind
    of nkTypeDef:
      unwrappableAST.add(node)
    of nkProcDef, nkFuncDef, nkMethodDef:
      wrappableAST.add(node)
    else:
      if showVerboseOutput:
        styledEcho fgYellow, "Unhandled AST: $#".format(node.kind)
  return (wrappableAST, unwrappableAST)

proc translateToCompatibleWrapperApi*(
    publicAST: seq[PNode]
): (string, seq[PNode], seq[PNode]) =
  let (wrappableAST, unwrappableAST) = separateWrappableAST(publicAST)
  if showVerboseOutput:
    styledEcho fgYellow, "Unwrappable AST:"
    for node in unwrappableAST:
      echo treeToYaml(configRef, node)
  let apiContent = generateWrapperApi(wrappableAST)
  if showVerboseOutput:
    styledEcho fgYellow, "Wrapped Apis:"
    echo apiContent
  return (apiContent, wrappableAST, unwrappableAST)
