# SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
#
# SPDX-License-Identifier: MIT

import
  std/[dirs, options, paths, sequtils, strformat, strutils, sugar, tables, terminal]
import compiler/ast
import convertutil, currentconfig, store, util, langs/base

proc relativeModulePath(): string =
  let relModFilePath = origFile.relativePath(bindingDirPath, '/')
  let relModPath = relModFilePath.changeFileExt("")
  result = relModPath.string

func handleCppEnums(enumASTs: seq[PNode]): (string, string) =
  var cppEnums, altEnums: seq[string]
  for enumNode in enumASTs:
    let enumName = enumNode.itemName
    let enumValParent = enumNode[2]
    var enumVals: seq[string]
    for i in 1 ..< enumValParent.safeLen:
      let (enumValName, enumValVal) = enumValParent[i].enumNameValue
      var val = enumValName
      if enumValVal.isSome:
        val = &"{val} = {enumValVal.unsafeGet}"
      enumVals.add(val)
    let cppEnum =
      &"""type {enumName}WrapEnum {{.
    importcpp: "{enumName}", header: "helper_types.h", nodecl, pure
  .}} = enum
    {enumVals.join("\n    ")}

  genConverter(to{enumName}, {enumName}WrapEnum, {enumName})"""
    let altEnum = &"""type {enumName}WrapEnum = {enumName}"""
    cppEnums.add(cppEnum)
    altEnums.add(altEnum)
  result = (cppEnums.join("\n\n  "), altEnums.join("\n  "))

func handleAnonymousTuples(
    anonymousTupleTbl: Table[string, string]
): (Table[string, string], Table[string, string]) =
  var jsTupleTbl, tupleTbl: Table[string, string]
  for key, val in anonymousTupleTbl.pairs:
    let memberTypes = val.split(",")
    let tupleDefJs = &"type {key} = seq[JsObject]"
    let tupleDef =
      &"""type {key}* {{.importc, header: "helper_types.h".}} = object
      {generateValNames(memberTypes.len).zip(memberTypes).map(x => x[0] & "*: " & nimAndCompatTypeTbl.getOrDefault(x[1], x[1])).join("\n      ")}"""
    jsTupleTbl[key] = tupleDefJs
    tupleTbl[key] = tupleDef
  result = (jsTupleTbl, tupleTbl)

func handleAnonymousCppTuples(
    tupleNames: seq[string], anonymousTupleSigTbl: Table[string, string]
): string =
  var cppTuples: seq[string]
  for tupleTypeName in tupleNames:
    let tupleSignature = anonymousTupleSigTbl[tupleTypeName]
    let memberTypes = tupleSignature.split(",")
    let tupleType = if memberTypes.len == 2: "CppPair" else: "CppTuple"
    let cppTuple =
      &"""type {tupleTypeName} = {tupleType}[{memberTypes.mapIt(nimAndCompatTypeTbl.getOrDefault(it, it)).join(", ")}]"""
    cppTuples.add(cppTuple)
  result = cppTuples.join("\n  ")

proc getCppDefs(
    unwrappableAST: seq[PNode],
    anonymousTupleTblJs: Table[string, string],
    anonymousTupleTbl: Table[string, string],
): string =
  var cppTypes, altTypes: seq[string]

  if useConstCStrType:
    let constCStrTypeCpp =
      &"""type ConstCString {{.importc: "const char*".}} = object

  converter toCString(
    self: ConstCString
  ): cstring {{.importc: "(char*)", noconv, nodecl.}}

  proc `$`(self: ConstCString): string =
    $(self.toCString)"""

    let constCStrTypeAlt = "type ConstCString = cstring"

    cppTypes.add(constCStrTypeCpp)
    altTypes.add(constCStrTypeAlt)

  if useCppEnumWrappers:
    let converterTemplate =
      &"""template genConverter(name: untyped, fromTyp, toTyp: typedesc) =
    converter `name`(
      self: fromTyp
    ): toTyp {{.importcpp: "static_cast<int>(@)", noconv, nodecl.}}"""

    let enumNodes =
      unwrappableAST.filterIt(it.kind == nkTypeDef).filterIt(it.subType == nkEnumTy)
    let (cppEnumWrappers, altEnumWrappers) = handleCppEnums(enumNodes)

    cppTypes.add(converterTemplate)
    cppTypes.add(cppEnumWrappers)
    altTypes.add(altEnumWrappers)

  if useCppPairTuple:
    let cppPairType =
      &"""type CppPair[T1, T2] {{.importcpp: "std::pair", header: "<utility>".}} = object

  proc val1[T1, T2](
    this: CppPair[T1, T2]
  ): T1 {{.importcpp: "#.first", header: "<utility>".}}

  proc val2[T1, T2](
    this: CppPair[T1, T2]
  ): T1 {{.importcpp: "#.second", header: "<utility>".}}

  proc makePair[T1, T2](
    a: T1, b: T2
  ): CppPair[T1, T2] {{.importcpp: "std::make_pair(@)", header: "<utility>".}}
  
  type CppTuple[T1, T2, T3] {{.importcpp: "std::tuple", header: "<tuple>".}} = object
  
  proc makeTuple[T1, T2, T3](
    a: T1, b: T2, c: T3
  ): CppTuple[T1, T2, T3] {{.importcpp: "std::make_tuple(@)", header: "<tuple>".}}"""
    let cppTuples =
      handleAnonymousCppTuples(anonymousTupleTbl.keys.toSeq, anonymousTuplesNameToSig)

    cppTypes.add(cppPairType)
    cppTypes.add(cppTuples)

  result =
    &"""when defined(cpp):
  {cppTypes.join("\n\n  ")}

else:
  {altTypes.join("\n  ")}
  when defined(js):
    {anonymousTupleTblJs.values.toSeq.join("\n    ")}
  else:
    {anonymousTupleTbl.values.toSeq.join("\n    ")}"""

proc generateWrapperFileContent(
    wrappedApis: string, unwrappableAST: seq[PNode], typeDefs, apiNames: seq[string]
): string =
  let modulePath = relativeModulePath()

  let stdImportFlagEnumsCommon = if flagEnums.len > 0: "import std/sequtils" else: ""

  let flagEnumsJsImport = if flagEnums.len > 0: "bitops" else: ""
  let tupleJsImport = if anonymousTuplesNameToSig.len > 0: "jsffi" else: ""
  let stdImportJsSeq = [flagEnumsJsImport, tupleJsImport].filterIt(it != "")
  let stdImportForJsPart =
    if stdImportJsSeq.len > 1:
      &"""[{stdImportJsSeq.join(", ")}]"""
    else:
      stdImportJsSeq[0]
  let stdImportForJs =
    &"""when defined(js):
  import std/{stdImportForJsPart}"""

  let importSection = [stdImportFlagEnumsCommon, stdImportForJs, &"import {modulePath}"]
    .filterIt(it != "")
    .join("\n")

  let q3 = "\"\"\""

  let helperPragma =
    &"""when defined(cpp):
  when defined(windows):
    {{.
      pragma: ffiexport,
      raises: [],
      exportcpp,
      codegenDecl: "__declspec(dllexport) $# $#$#"
    .}}
  else:
    {{.
      pragma: ffiexport,
      raises: [],
      exportcpp,
      codegenDecl: {q3}__attribute__((visibility("default"))) $# $#$#{q3}
    .}}
else:
  {{.pragma: ffiexport, raises: [], exportc, cdecl, dynlib.}}"""

  let vccCondImport =
    if shouldUseVCCStr:
      &"""when defined(vcc):
  proc CoTaskMemAlloc(cb: int): cstring {{.cdecl, dynlib: "ole32.dll", importc.}}"""
    else:
      ""

  let (jsTupleTbl, tupleTbl) = handleAnonymousTuples(anonymousTuplesNameToSig)
  let cppDefs = getCppDefs(unwrappableAST, jsTupleTbl, tupleTbl)

  # extern "C" is hardcoded for NimMain for cpp dynamic lib compilation, so workaround applied.
  let nimMainStr =
    &"""when defined(cpp):
  proc NimMain*() {{.raises: [], exportcpp, cdecl, dynlib, importc.}}
else:
  proc NimMain*() {{.ffiexport, importc.}}"""

  let startingParts = [importSection, helperPragma, vccCondImport, cppDefs, nimMainStr]
    .filterIt(it != "")
    .join("\n\n")

  var exportedApiNames = &"""{{ {apiNames.join(", ")} }}"""
  if exportedApiNames.len > (80 - 8):
    exportedApiNames =
      &"""
{{
  {apiNames.join(",\n  ")}
}}"""

  let endingParts =
    &"""when defined(js):
  {{.
    emit: {q3}

{typeDefs.join("\n\n")}

export {exportedApiNames};
{q3}
  .}}"""

  result =
    &"""
{startingParts}

{wrappedApis}

{endingParts}
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

  let jsLangGen = BaseLangGen()
  let typeDefs = jsLangGen.typeDefinitions(unwrappableAST)
  let apiNames = concat(unwrappableAST, wrappableAST).map(x => x.itemName).filter(
      x => x notin jsLangGen.ignoreApiList
    )
  let fileContent =
    generateWrapperFileContent(wrappedApis, unwrappableAST, typeDefs, apiNames)
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
