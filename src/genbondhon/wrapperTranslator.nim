# SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
#
# SPDX-License-Identifier: MIT

import std/[options, strformat, strutils, tables, terminal]
import compiler/[ast, astalgo]
import convertutil, currentconfig, store, util

func replaceType(nimType: string): string =
  nimAndCompatTypeTbl.getOrDefault(nimType, nimType)

proc convertType(
    code: string,
    origType: string,
    convertDirection: ConvertDirection,
    isFlagEnum: bool = false,
): string =
  let oType =
    if isFlagEnum:
      flagEnumSets[origType]
    else:
      origType
  convertNimAndCompatType(oType, code, isFlagEnum, convertDirection)

proc translateProc(node: PNode): string =
  let procName = node.itemName
  let paramNode = procParamNode(node)
  if paramNode.isNone:
    styledEcho fgRed, "Error!!! FormalParamNode missing!"
  let formalParamNode = paramNode.get()
  var trParamList, callableParamList, callableParamListJs, flagNameListJs =
    newSeq[string]()
  var hasFlagEnum = false
  for i in 1 ..< formalParamNode.safeLen:
    let paramName = formalParamNode[i].paramName
    let paramType = formalParamNode[i].paramType
    var trParamType = paramType.replaceType
    if flagEnums.contains(paramType):
      hasFlagEnum = true
      trParamType = "cint"
      var procTable = flagEnumRevrsLookupTbl.mgetOrPut(procName)
      procTable[paramName] = paramType
      flagEnumRevrsLookupTbl[procName] = procTable
    let trParam = &"{paramName}: {trParamType}"
    trParamList.add(trParam)
    if hasFlagEnum:
      if callableParamListJs.len == 0:
        callableParamListJs = callableParamList
      let callableParamJs = paramName & "Flag"
      flagNameListJs.add(callableParamJs)
      callableParamListJs.add(callableParamJs)
    let callableParam =
      &"{paramName.convertType(paramType.replaceType, ConvertDirection.fromC, flagEnums.contains(paramType))}"
    callableParamList.add(callableParam)
  let origRetType =
    if formalParamNode[0].kind != nkEmpty:
      formalParamNode[0].ident.s
    else:
      ""
  var retType = origRetType
  if flagEnums.contains(origRetType):
    hasFlagEnum = true
    retType = "int"
    var procTable = flagEnumRevrsLookupTbl.mgetOrPut(procName)
    procTable[retTypeLookupKey] = origRetType
    flagEnumRevrsLookupTbl[procName] = procTable
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
      &"return {procCallStmt.convertType(origRetType, ConvertDirection.toC, flagEnums.contains(origRetType))}"
  if shouldUseVCCStr and retType == "string":
    retBody =
      &"""when defined(vcc):
    let nimstr = {procCallStmt}
    let cstr = CoTaskMemAlloc(nimstr.len + 1)
    {{.emit: ["strcpy(", cstr, ", ", nimstr.cstring, ");"].}}
    return cstr
  else:
    {retBody}"""
  if hasFlagEnum:
    var flagLines: seq[string]
    for flag in flagNameListJs:
      var paramName = flag
      paramName.removeSuffix("Flag")
      let paramType = flagEnumRevrsLookupTbl[procName][paramName]
      let flagConvLine =
        &"""
    let {flag} = {paramName}.int.fastLog2.{paramType}"""
      flagLines.add(flagConvLine)
    var retLineJs = &"""{moduleName}.{procName}({callableParamListJs.join(", ")})"""
    if retType != "":
      retLineJs =
        if flagEnums.contains(origRetType):
          &"return 1 shl {retLineJs}.int"
        else:
          &"return {retLineJs}"
    let jsBody =
      if flagLines.len > 0:
        &"""{flagLines.join("\n")}
    {retLineJs}"""
      else:
        &"""
    {retLineJs}"""
    retBody =
      &"""when defined(js):
{jsBody}
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

proc preprocessTypes(node: PNode) =
  case node.subType
  of nkEnumTy:
    namedTypes[node.itemName] = NamedTypeCategory.enumType
  of nkBracketExpr:
    let containerType = node[2][0].ident.s
    let memberType = node[2][1].ident.s
    if containerType == "set":
      namedTypes[node.itemName] = NamedTypeCategory.setType
      if namedTypes.getOrDefault(memberType, NamedTypeCategory.noneType) ==
          NamedTypeCategory.enumType:
        flagEnums.add(memberType)
        flagEnumSets[memberType] = node.itemName
  else:
    discard

proc separateWrappableAST(publicAST: seq[PNode]): (seq[PNode], seq[PNode]) =
  ## separate public AST into wrappable and unwrappable ASTs
  var wrappableAST, unwrappableAST: seq[PNode]
  for node in publicAST:
    case node.kind
    of nkTypeDef:
      node.preprocessTypes()
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
