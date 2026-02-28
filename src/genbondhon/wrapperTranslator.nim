# SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
#
# SPDX-License-Identifier: MIT

import std/[options, sequtils, strformat, strutils, sugar, tables, terminal]
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

proc getRegAnonymousTupleType(node: PNode): string =
  ## get registered anonymous tuple type name matching the signature if available
  ## or create, register and return new anonymous tuple type name
  let memberTypes = node.sons.map(x => x.ident.s)
  let signature = memberTypes.join(",")
  if signature in anonymousTuplesSigToName:
    return anonymousTuplesSigToName[signature]
  var isHomogenous = true
  let firstType = memberTypes[0]
  for i in 1 ..< memberTypes.len:
    if memberTypes[i] != firstType:
      isHomogenous = false
      break
  if isHomogenous:
    result = &"{firstType.capitalizeAscii}{memberTypes.len}Tuple"
  else:
    result = memberTypes[0].capitalizeAscii
    var count = 1
    for i in 1 ..< memberTypes.len:
      if memberTypes[i - 1] == memberTypes[i]:
        count = count + 1
        if count > 2:
          let numIndex = result.rfind($count)
          result = result[0 ..< numIndex - 1] & $count
        else:
          result = result & $count
      else:
        count = 1
        result = result & memberTypes[i].capitalizeAscii
    result = result & "Tuple"
  anonymousTuplesSigToName[signature] = result
  anonymousTuplesNameToSig[result] = signature

func convertProcParamTypeForCppCompilation(
    paramType: string, namedTypeTbl: Table[string, NamedTypeCategory]
): string =
  if paramType == "cstring":
    result = "ConstCString"
  elif namedTypeTbl.getOrDefault(paramType, NamedTypeCategory.noneType) ==
      NamedTypeCategory.enumType:
    result = paramType & "WrapEnum"
  else:
    result = paramType

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
    var paramIsFlagEnum = false
    let paramNames = formalParamNode[i].paramNames
    let formalParamTypeNode = formalParamNode[i][formalParamNode[i].len - 2]
    let paramType =
      if formalParamTypeNode.kind == nkTupleConstr:
        formalParamTypeNode.getRegAnonymousTupleType()
      else:
        formalParamNode[i].paramType
    var trParamType = paramType.replaceType
    trParamType = convertProcParamTypeForCppCompilation(trParamType, namedTypes)
    if flagEnums.contains(paramType):
      hasFlagEnum = true
      paramIsFlagEnum = true
      var procTable = flagEnumRevrsLookupTbl.mgetOrPut(procName)
      for paramName in paramNames:
        procTable[paramName] = paramType
      flagEnumRevrsLookupTbl[procName] = procTable
    let trParam = &"""{paramNames.join(", ")}: {trParamType}"""
    trParamList.add(trParam)
    var valNames: seq[string]
    var tupleMemberTypes: seq[string]
    if anonymousTuplesNameToSig.contains(paramType):
      tupleMemberTypes = anonymousTuplesNameToSig[paramType].split(",")
      valNames = generateValNames(tupleMemberTypes.len)
    for paramName in paramNames:
      let paramNameCopy = paramName
      let callableParam =
        if anonymousTuplesNameToSig.contains(paramType):
          &"""({valNames.zip(tupleMemberTypes).map(x => paramNameCopy & "." & x[0].convertType(x[1].replaceType, ConvertDirection.fromC, flagEnums.contains(x[1].replaceType))).join(", ")})"""
        else:
          &"{paramName.convertType(paramType.replaceType, ConvertDirection.fromC, flagEnums.contains(paramType))}"
      if paramIsFlagEnum:
        if callableParamListJs.len == 0:
          callableParamListJs = callableParamList
        let callableParamJs = paramName & "Flag"
        flagNameListJs.add(callableParamJs)
        callableParamListJs.add(callableParamJs)
      else:
        callableParamListJs.add(callableParam)
      callableParamList.add(callableParam)
  let origRetType =
    case formalParamNode[0].kind
    of nkEmpty:
      ""
    of nkTupleConstr:
      formalParamNode[0].getRegAnonymousTupleType()
    else:
      formalParamNode[0].ident.s
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
  let valNames =
    if anonymousTuplesNameToSig.contains(retType):
      generateValNames(callableParamList.len)
    else:
      @[]
  let tupleMemberTypes =
    if anonymousTuplesNameToSig.contains(retType):
      anonymousTuplesNameToSig[retType].split(",")
    else:
      @[]
  var retBody =
    if retType == "":
      procCallStmt
    elif anonymousTuplesNameToSig.contains(retType):
      &"""let ({valNames.join(", ")}) = {procCallStmt}
  when defined(cpp):
    return {(if true: "makePair" else: "makeTuple")}({valNames.zip(tupleMemberTypes).map(x => "$#" % [x[0].convertType(x[1], ConvertDirection.toC, flagEnums.contains(x[1]))]).join(", ")})
  elif defined(js):
    return @[{valNames.zip(tupleMemberTypes).map(x => "$#.toJs" % [x[0].convertType(x[1], ConvertDirection.toC, flagEnums.contains(x[1]))]).join(", ")}]
  else:
    return {retType}({valNames.zip(tupleMemberTypes).map(x => "$#: $#" % [x[0], x[0].convertType(x[1], ConvertDirection.toC, flagEnums.contains(x[1]))]).join(", ")})"""
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
proc {procName}*({trParamList.join(", ")}){retTypePart} {{.ffiexport.}} =
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
{trApis.join("\n\n")}"""

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
