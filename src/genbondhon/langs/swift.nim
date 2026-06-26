# SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
#
# SPDX-License-Identifier: MIT

import std/[options, os, paths, sequtils, strformat, strutils, sugar, tables, terminal]
import compiler/ast
import base
import ../[convertutil, currentconfig, store, util]

type SwiftLangGen = ref object of BaseLangGen
  cModuleName: string
  cLangDir: Path
  wrapperFileName: Path
  headerFileName: string
  moduleMapName: Path

proc newSwiftLangGen*(bindingDir: Path): SwiftLangGen =
  ## `SwiftLangGen` constructor
  result = SwiftLangGen(
    langDir: bindingDir / "Swift".Path,
    cModuleName: "C" & moduleName.capitalizeAscii,
    cLangDir: bindingDir / "C".Path,
    wrapperFileName: moduleName.Path.addFileExt("swift"),
    headerFileName: moduleName.Path.addFileExt("h").string,
    moduleMapName: "module".Path.addFileExt("modulemap"),
  )
  initBaseLangGen(result)

func replaceType(nimSwiftType: string): string =
  ## Replaces Nim Compat Types to Swift Types & vice versa
  nimCompatAndSwiftTypeTbl.getOrDefault(nimSwiftType, nimSwiftType)

func convertType(
    code: string,
    origType: string,
    convertDirection: ConvertDirection,
    moduleName: string,
    namedTypeCategory: NamedTypeCategory = NamedTypeCategory.noneType,
): string =
  convertNimAndSwiftType(
    origType, code, convertDirection, moduleName, namedTypeCategory
  )

func swiftCModuleDir(self: SwiftLangGen): Path =
  self.langDir / self.cModuleName.Path

proc copyCHeader(self: SwiftLangGen) =
  ## Copies C Header from C output
  let cDirHeaderPath = self.cLangDir / self.headerFileName.Path
  self.ensureDir(self.swiftCModuleDir)
  cDirHeaderPath.string.copyFileToDir(self.swiftCModuleDir.string)

func generateModuleMapContent(self: SwiftLangGen, libName: string): string =
  result =
    &"""
module {self.cModuleName} {{
  header "{self.headerFileName}"
  link "{libName}"
  export *
}}
"""

proc generateModuleMap(self: SwiftLangGen) =
  let content = self.generateModuleMapContent(moduleName)
  if showVerboseOutput:
    styledEcho fgGreen, "Swift C modulemap content:"
    echo content
  let moduleMapFilePath = self.swiftCModuleDir / self.moduleMapName
  moduleMapFilePath.string.writeFile(content)

method translateEnum(self: SwiftLangGen, node: PNode): (string, string) =
  let enumName = node.itemName
  self.storeNamedType(enumName, NamedTypeCategory.enumType)
  let enumValsParent = node[2]
  var enumVals: seq[string]
  for i in 1 ..< enumValsParent.safeLen:
    let (enumValName, enumValVal) = enumValsParent[i].enumNameValue
    var val =
      &"""
case {enumValName.toLowerAscii}"""
    if enumValVal.isSome:
      val = &"{val} = {enumValVal.unsafeGet}"
    enumVals.add(val)
  let trResult =
    &"""
enum {enumName}: CUnsignedInt {{
    {enumVals.join("\n    ")}
}}"""
  result = (enumName, trResult)

func convertTypeToStdType(
    paramType: string, tupleNameSigTbl: Table[string, string]
): string =
  if tupleNameSigTbl.contains(paramType):
    let signature = tupleNameSigTbl[paramType]
    let memberTypes = signature.split(",")
    let memberList = memberTypes.mapIt(it.replaceType).join(", ")
    result = &"({memberList})"
  else:
    result = paramType

func translateProc(
    self: SwiftLangGen,
    node: PNode,
    flagLookupTbl: Table[string, Table[string, string]],
    flagEnumSeq: seq[string],
    namedTypeTbl: Table[string, NamedTypeCategory],
    tupleNameSigTbl: Table[string, string],
): (string, string) =
  let funcName = node.itemName
  let hasFlagEnum = flagLookupTbl.contains(funcName)
  let paramNode = procParamNode(node)
  var retType = ""
  var trParamList, callableParamList: seq[string]
  var stringMemberTuples: seq[(string, int)] # (paramName, memberIndex)
  if paramNode.isSome:
    let formalParamNode = paramNode.get()
    for i in 1 ..< formalParamNode.safeLen:
      let paramNames = formalParamNode[i].paramNames
      var paramType = formalParamNode[i].paramType
      paramType = paramType.revertParamTypeToNimNativeType(namedTypeTbl)
      let origParamType =
        if hasFlagEnum:
          checkRestoreFlagEnumType(paramNames[0], paramType, flagLookupTbl[funcName])
        else:
          paramType.convertTypeToStdType(tupleNameSigTbl)
      for paramName in paramNames:
        let trParam = &"{paramName}: {origParamType.replaceType}"
        trParamList.add(trParam)
        var callableParam = paramName
        let paramNameCopy = paramName
        if tupleNameSigTbl.contains(paramType):
          let memberTypes = tupleNameSigTbl[paramType].split(",")
          stringMemberTuples = (0 ..< memberTypes.len).toSeq
            .zip(memberTypes)
            .filterIt(it[1] == "cstring")
            .map(x => (paramNameCopy, x[0]))
          callableParam =
            &"""{paramType}({(1..memberTypes.len).toSeq.zip(memberTypes).map(x =>
              "val$#: $#" % [$x[0], (
                if x[1] == "cstring": paramNameCopy & $(x[0]-1) & "CStr" else: paramNameCopy & "." & $(x[0]-1)
              ).convertType(x[1].replaceType, ConvertDirection.toC, self.cModuleName, self.typeCategory(x[1]))]
            ).join(", ")})"""
        else:
          callableParam = paramName.convertType(
            origParamType.replaceType,
            ConvertDirection.toC,
            self.cModuleName,
            self.typeCategory(origParamType),
          )
        callableParamList.add(callableParam)
    if formalParamNode[0].kind != nkEmpty:
      retType = formalParamNode[0].ident.s
  let origRetType =
    if hasFlagEnum:
      checkRestoreFlagEnumType(retTypeLookupKey, retType, flagLookupTbl[funcName])
    elif tupleNameSigTbl.contains(retType):
      convertTypeToStdType(retType, tupleNameSigTbl)
    else:
      retType
  let retTypePart =
    if origRetType == "":
      ""
    else:
      &" -> {origRetType.replaceType}"
  let procCallStmt =
    &"""{self.cModuleName}.{funcName}({callableParamList.join(", ")})"""
  var retBody =
    if origRetType == "":
      procCallStmt
    else:
      &"return {procCallStmt.convertType(origRetType, ConvertDirection.fromC, self.cModuleName, self.typeCategory(origRetType))}"
  if origRetType.replaceType == "String":
    retBody =
      &"""let temp = {procCallStmt}
    guard let data = temp else {{
        print("Error!! Failed to get string from {funcName}")
        return "Failed to get string from {funcName}"
    }}
    return {"data".convertType(origRetType, ConvertDirection.fromC, self.cModuleName)}"""
  elif self.typeCategory(origRetType) == NamedTypeCategory.enumType:
    if flagEnumSeq.contains(origRetType):
      retBody =
        &"""let cEnum = {procCallStmt}
    let data = {"cEnum".convertType(origRetType, ConvertDirection.fromC, self.cModuleName, self.typeCategory(origRetType))}
    return data"""
    else:
      retBody =
        &"""let cEnum = {procCallStmt}
    let sEnum = {"cEnum".convertType(origRetType, ConvertDirection.fromC, self.cModuleName, self.typeCategory(origRetType))}
    guard let data = sEnum else {{
        fatalError("Error!! Failed to get enum {origRetType} from {funcName}")
    }}
    return data"""
  elif tupleNameSigTbl.contains(retType):
    let memberTypesCompat = tupleNameSigTbl[retType].split(",")
    let memberNames = memberTypesCompat.len.generateValNames()
    retBody =
      &"""let cTuple = {procCallStmt}
    return ({memberNames.zip(memberTypesCompat).map(x => "cTuple.$#".format(x[0]).convertType(x[1], ConvertDirection.fromC, self.cModuleName)).join(", ")})"""
  for (paramName, index) in stringMemberTuples:
    retBody =
      &"""{paramName}.{index}.withCString {{ {paramName}{index}CStr in
        {retBody.split("\n").join("\n    ")}
    }}"""
  if stringMemberTuples.len > 0 and retType != "":
    retBody = &"return {retBody}"
  let trResult =
    &"""
func {funcName}({trParamList.join(", ")}){retTypePart} {{
    {retBody}
}}"""
  result = (funcName, trResult)

func translateApi(
    self: SwiftLangGen,
    api: PNode,
    flagTbl: Table[string, Table[string, string]],
    flagList: seq[string],
    namedTypeTbl: Table[string, NamedTypeCategory],
    tupleNameSigTbl: Table[string, string],
): (string, string) =
  case api.kind
  of nkTypeDef:
    result = self.translateType(api)
  of nkProcDef, nkFuncDef, nkMethodDef:
    result = self.translateProc(api, flagTbl, flagList, namedTypeTbl, tupleNameSigTbl)
  else:
    result = (api.itemName, "Cannot translate Api to Swift")

method convertEnumToEnumFlag(self: SwiftLangGen, enumBody: string): string =
  let enumBodyLines = enumBody.splitLines
  let itemLines = enumBodyLines[1 ..^ 2]
  let enumName = enumBodyLines[0].split(": ")[0].split(' ')[^1]
  var flagLines: seq[string]
  for i in 0 ..< itemLines.len:
    let enumVal = &"1 << {i}"
    let itemParts = itemLines[i].split("case ")
    let item =
      itemParts[0] & &"static let {itemParts[^1]} = {enumName}(rawValue: {enumVal})"
    flagLines.add(item)
  result =
    &"""struct {enumName}: OptionSet {{
    let rawValue: CUnsignedInt

{flagLines.join("\n")}
}}
"""

proc generateSwiftWrapperContent(
    self: SwiftLangGen, bindingAST: seq[PNode], modName: string
): string =
  var swiftApis: OrderedTable[string, string]
  for api in bindingAST:
    let (apiId, trApi) = self.translateApi(
      api, flagEnumRevrsLookupTbl, flagEnums, namedTypes, anonymousTuplesNameToSig
    )
    swiftApis[apiId] = trApi
  swiftApis = self.handleEnumFlags(swiftApis)
  swiftApis = collect(initOrderedTable):
    for k, v in swiftApis.pairs:
      if v != "":
        {k: v}
  result =
    &"""
import {self.cModuleName}

{swiftApis.values.toseq.join("\n\n")}
"""

proc generateSwiftWrapper(self: SwiftLangGen, bindingAST: seq[PNode]) =
  let content = self.generateSwiftWrapperContent(bindingAST, moduleName)
  if showVerboseOutput:
    styledEcho fgGreen, "Swift Wrapper Content:"
    echo content
  let wrapperFilePath = self.swiftCModuleDir / self.wrapperFileName
  wrapperFilePath.string.writeFile(content)

method getReadMeContent(self: SwiftLangGen): string =
  let common = procCall self.BaseLangGen.getReadMeContent()
  let bindingMacosPath = self.langDir / "macOS".Path
  let bindingIosPath = self.langDir / "iOS".Path
  let headerFilePath = self.swiftCModuleDir / self.headerFileName.Path
  let realTestDir = testDirPath / "Swift".Path
  let realTestDirMac = realTestDir / "macOS".Path
  let realTestDirIos = realTestDir / "iOS".Path
  let testDirSwiftModuleMac = realTestDirMac / self.cModuleName.Path
  let testDirSwiftModuleIos = realTestDirIos / self.cModuleName.Path
  let staticLibName = "lib$#.a".format(moduleName).Path
  let iosCacheDir = "iosCache"
  let tempIosDir = "iOS".Path
  let tempIosSimulatorDir = "iOSSimulator".Path
  let staticx64 = "lib$#-x64.a".format(moduleName).Path
  let staticarm64 = "lib$#-arm64.a".format(moduleName).Path
  let xcframeworkName = "lib$#.xcframework".format(moduleName).Path
  result =
    &"""
{common}

### Note
This generated module can be used in both macOS and iOS.

### macOS
#### Static Library

    nim c -d:release --noMain:on --app:staticlib --outdir:{bindingMacosPath.string} {self.bindingModuleFile.string}

#### Dynamic Library
Not supported

#### Usage
Copy the module and lib binary to your project. Put the lib binary inside module directory.

    mkdir {realTestDirMac.string}
    cp -r {self.swiftCModuleDir.string} {testDirSwiftModuleMac.string}
    cp {string bindingMacosPath / staticLibName} {testDirSwiftModuleMac.string}

Then see [Setup Xcode](#setup-xcode)

### iOS
#### Static Library
First, compile the nim code to C code for iOS with the following command.

    nim c -c -d:release --os:ios --noMain:on --app:staticLib --nimcache:{iosCacheDir} {self.bindingModuleFile.string}

Then compile the C code for iOS and archive the obj files to static library.
You have to build & archive for iPhone device and simulator separately. Remove the obj files between separate builds.
Provide the directory of `"nimbase.h"` for include.
Provide all generated C files. It will generate .o files.

##### iPhone Device

    cd {iosCacheDir}
    xcrun -sdk iphoneos clang -c -arch arm64 -I /usr/local/Cellar/nim/2.0.4/nim/lib *.c
    cd ..
    mkdir {tempIosDir.string}
    ar r {string tempIosDir / staticLibName} {iosCacheDir}/*.o

##### iPhone Simulator

For iPhone Simulator, build for both x86_64 and arm64.

    rm {iosCacheDir}/*.o
    cd {iosCacheDir}
    xcrun -sdk iphonesimulator clang -c -arch x86_64 -I /usr/local/Cellar/nim/2.0.4/nim/lib *.c
    cd ..
    mkdir {tempIosSimulatorDir.string}
    ar r {string tempIosSimulatorDir / staticx64} {iosCacheDir}/*.o
    rm {iosCacheDir}/*.o
    cd {iosCacheDir}
    xcrun -sdk iphonesimulator clang -c -arch arm64 -I /usr/local/Cellar/nim/2.0.4/nim/lib *.c
    cd ..
    ar r {string tempIosSimulatorDir / staticarm64} {iosCacheDir}/*.o

Use lipo to create fat binary.

    lipo -create -output {string tempIosSimulatorDir / staticLibName} {string tempIosSimulatorDir / staticx64} {string tempIosSimulatorDir / staticarm64}

===

Create XCFramework from the static libraries.

    xcodebuild -create-xcframework -library {string tempIosDir / staticLibName} -headers {headerFilePath.string} -library {string tempIosSimulatorDir / staticLibName} -headers {headerFilePath.string} -output {string bindingIosPath / xcframeworkName}

Remove {iosCacheDir}, iOS, iOSSimulator directories. They aren't neeeded anymore.

    rm -r {iosCacheDir} {tempIosDir.string} {tempIosSimulatorDir.string}

#### Dynamic Library
Not supported

#### Usage
Copy the module and lib binary to your project. Put the lib binary inside module directory.

    cp -r {self.swiftCModuleDir.string}/ {testDirSwiftModuleIos.string}/
    cp -r {string bindingIosPath / xcframeworkName} {testDirSwiftModuleIos.string}

Then see [Setup Xcode](#setup-xcode)

### Setup Xcode
In Xcode, add the module directory's parent to `Swift Compiler - Search Paths` > `Import Paths`.
Do not include the module directory itself in the path.

For example, let's say you have put the module directory in {string realTestDirMac / "CommandLineApplication1/CommandLineApplication1".Path / self.cModuleName.Path},
then you should add `$(PROJECT_DIR)/CommandLineApplication1` to the search path > import path.
$(PROJECT_DIR) refers to the directory with .xcproj file.
So the path will be {string realTestDirMac / "CommandLineApplication1/CommandLineApplication1".Path}, the parent directory of {self.cModuleName}.

Then add the path of {staticLibName.string} to `Library Search Paths`,
e.g. {string "$(PROJECT_DIR)/CommandLineApplication1".Path / self.cModuleName.Path},
which will resolve to {string realTestDirMac / "CommandLineApplication1/CommandLineApplication1".Path / self.cModuleName.Path}
"""

method generateBinding*(self: SwiftLangGen, bindingAST: seq[PNode]) =
  ## Generates binding & documentation for Swift
  self.copyCHeader()
  self.generateModuleMap()
  self.generateSwiftWrapper(bindingAST)
  self.generateReadMe()
