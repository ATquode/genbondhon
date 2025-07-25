# SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
#
# SPDX-License-Identifier: MIT

import std/[options, os, paths, strformat, strutils, tables, terminal]
import base
import compiler/ast
import ../[convertutil, currentconfig, util]

const androidAbiArchArray = [
  (arch: "arm64", abi: "arm64-v8a", target: "aarch64"),
  (arch: "arm", abi: "armeabi-v7a", target: "armv7a"),
  (arch: "i386", abi: "x86", target: "i686"),
  (arch: "amd64", abi: "x86_64", target: "x86_64"),
]

type KotlinLangGen = ref object of BaseLangGen
  cppModuleDir: Path
  cppLangDir: Path
  wrapperFileName: Path
  jvmPackageName: string
  headerFileName: Path
  namedTypes: Table[string, NamedTypeCategory]

proc newKotlinLangGen*(bindingDir: Path, jvmPkgName: string): KotlinLangGen =
  ## `KotlinLangGen` constructor
  result = KotlinLangGen(
    langDir: bindingDir / "Kotlin".Path,
    cppModuleDir: bindingDir / "Kotlin".Path / "cpp".Path,
    cppLangDir: bindingDir / "C++".Path,
    wrapperFileName: moduleName.capitalizeAscii.Path.addFileExt("kt"),
    jvmPackageName: jvmPkgName,
    headerFileName: moduleName.Path.addFileExt("hpp"),
  )
  initBaseLangGen(result)

func replaceTypeJNI(nimJNIType: string): string =
  ## Replaces Nim Compat Types to JNI Types & vice versa
  nimCompatAndJNITypeTbl.getOrDefault(nimJNIType, nimJNIType)

func convertTypeJNI(
    code: string,
    origType: string,
    namedTypeCategory: NamedTypeCategory = NamedTypeCategory.noneType,
): string =
  convertNimAndJNIType(origType, code, namedTypeCategory)

proc storeNamedType(
    self: KotlinLangGen, typeName: string, typeCategory: NamedTypeCategory
) =
  if typeName in self.namedTypes:
    return
  self.namedTypes[typeName] = typeCategory

proc copyCppHeader(self: KotlinLangGen) =
  ## Copies C++ Header from C++ Output
  let cppLangDirHeaderPath = self.cppLangDir / self.headerFileName
  self.ensureDir(self.cppModuleDir)
  cppLangDirHeaderPath.string.copyFileToDir(self.cppModuleDir.string)

func typeCategory(self: KotlinLangGen, typeName: string): NamedTypeCategory =
  self.namedTypes.getOrDefault(typeName, NamedTypeCategory.noneType)

func startLowerCase(s: string): string =
  if s.len == 0:
    return s
  let firstChar = s[0]
  if firstChar.isLowerAscii:
    return s
  let lowerChar = firstChar.toLowerAscii
  if s.len == 1:
    return $lowerChar
  let newString = lowerChar & s[1 ..^ 1]
  return newString

func wrapperFuncName(funcName: string): string =
  funcName.startLowerCase & "Val"

func jniFuncName(jvmPkgName: string, className: string, origFuncName: string): string =
  &"""Java_{jvmPkgName.replace(".", "_")}_{className.capitalizeAscii}_{origFuncName.startLowerCase}"""

func translateProcToJNI(self: KotlinLangGen, node: PNode, className: string): string =
  let funcName = procName(node)
  var wrFuncName = funcName
  let paramNode = procParamNode(node)
  var retType = "void"
  var trParamList = @["JNIEnv *env", "jobject thiz"]
  var callableParamList: seq[string]
  var jstringTbl: Table[string, string]
  var jenumTbl: Table[string, (string, string)]
  if paramNode.isSome:
    let formalParamNode = paramNode.get()
    for i in 1 ..< formalParamNode.safeLen:
      let paramName = formalParamNode[i].paramName
      let paramType = formalParamNode[i].paramType
      var trParamType = paramType.replaceTypeJNI
      if self.typeCategory(paramType) == NamedTypeCategory.enumType:
        trParamType = "jint" # Kotlin enum -> JNI jint
        wrFuncName = funcName.wrapperFuncName
      let trParam = &"{trParamType} {paramName}"
      trParamList.add(trParam)

      if trParamType == "jstring":
        jstringTbl[paramName] = "c_" & paramName
        callableParamList.add(jstringTbl[paramName])
      elif self.typeCategory(paramType) == NamedTypeCategory.enumType:
        jenumTbl[paramName] = ("c_" & paramName, paramType)
        callableParamList.add(jenumTbl[paramName][0])
      else:
        let callableParam = paramName.convertTypeJNI(trParamType)
        callableParamList.add(callableParam)
    if formalParamNode[0].kind != nkEmpty:
      retType = formalParamNode[0].ident.s
  if not wrFuncName.contains("Val") and
      self.typeCategory(retType) == NamedTypeCategory.enumType:
    wrFuncName = funcName.wrapperFuncName
  let procCallStmt = &"""{funcName}({callableParamList.join(", ")})"""
  var retBody =
    if retType == "void":
      &"{procCallStmt};"
    else:
      &"return {procCallStmt.convertTypeJNI(retType, self.typeCategory(retType))};"
  if jstringTbl.len > 0:
    var getStrings, releaseStrings: seq[string]
    for key, value in jstringTbl:
      let getStrCode = &"const char* {value} = env->GetStringUTFChars({key}, nullptr);"
      getStrings.add(getStrCode)
      let releaseStrCode = &"env->ReleaseStringUTFChars({key}, {value});"
      releaseStrings.add(releaseStrCode)
    let procCallLine =
      if retType == "void":
        procCallStmt
      else:
        &"auto data = {procCallStmt}"
    retBody =
      &"""
{getStrings.join("\n    ")}
    {procCallLine};
    {releaseStrings.join("\n    ")}"""

    if retType != "void":
      retBody =
        &"""
{retBody}
    return {"data".convertTypeJNI(retType, self.typeCategory(retType))};"""
  if jenumTbl.len > 0:
    var getEnums: seq[string]
    for key, value in jenumTbl:
      let getEnumCode =
        &"""auto {value[0]} = static_cast<{value[1]}>({key.convertTypeJNI("jint")});"""
      getEnums.add(getEnumCode)
    retBody =
      &"""
{getEnums.join("\n    ")}
    {retBody}"""

  result =
    &"""
extern "C"
JNIEXPORT {retType.replaceTypeJNI} JNICALL
{jniFuncName(self.jvmPackageName, className, wrFuncName)}({trParamList.join(", ")}) {{
    {retBody}
}}"""

proc translateApiToJNI(self: KotlinLangGen, api: PNode, className: string): string =
  case api.kind
  of nkTypeDef:
    result = "" # C/C++ header has the definition
  of nkProcDef, nkFuncDef, nkMethodDef:
    result = self.translateProcToJNI(api, className)
  else:
    result = "Cannot translate Api to JNI"

proc generateJNIWrapperContent(
    self: KotlinLangGen, bindingAST: seq[PNode], className: string
): string =
  var jniApis: seq[string]
  for api in bindingAST:
    let trApi = self.translateApiToJNI(api, className)
    if trApi != "":
      jniApis.add(trApi)
  result =
    &"""
#include <jni.h>
#include "{self.headerFileName.string}"

{jniApis.join("\n\n")}
"""

func jniWrapperFileName(modName: string): string =
  modName & "JNI.cpp"

func className(modName: string): string =
  modName.capitalizeAscii

proc generateJNIWrapper(self: KotlinLangGen, bindingAST: seq[PNode]) =
  let content = self.generateJNIWrapperContent(bindingAST, moduleName.className)
  if showVerboseOutput:
    styledEcho fgGreen, "JNI wrapper content:"
    echo content
  let jniWrapperFilePath = self.cppModuleDir / moduleName.jniWrapperFileName.Path
  jniWrapperFilePath.string.writeFile(content)

func jniLibName(modName: string): string =
  &"{modName}JNI"

func generateCMakeListsContent(self: KotlinLangGen, modName: string): string =
  result =
    &"""
cmake_minimum_required(VERSION 3.22.1)

project("{modName.jniLibName}")

add_library(${{PROJECT_NAME}} SHARED
        {modName.jniWrapperFileName} {self.headerFileName.string})

find_library(log-lib log)
target_link_libraries(${{PROJECT_NAME}}
        ${{CMAKE_CURRENT_LIST_DIR}}/${{ANDROID_ABI}}/lib{modName}.a
        android
        ${{log-lib}})
"""

proc generateCMakeLists(self: KotlinLangGen) =
  let content = self.generateCMakeListsContent(moduleName)
  if showVerboseOutput:
    styledEcho fgGreen, "android CMakeLists content:"
    echo content
  let cmakeFilePath = self.cppModuleDir / "CMakeLists.txt".Path
  cmakeFilePath.string.writeFile(content)

func replaceType(nimCType: string): string =
  ## Replaces Nim Compat Types to Kotlin Types
  nimCompatToKotlinTypeTbl.getOrDefault(nimCType, nimCType)

method translateEnum(self: KotlinLangGen, node: PNode): string =
  let enumName = node.itemName
  self.storeNamedType(enumName, NamedTypeCategory.enumType)
  let enumValsParent = node[2]
  var enumVals: seq[string]
  for i in 1 ..< enumValsParent.safeLen:
    let enumVal = enumValsParent[i].ident.s
    let val =
      &"""
{enumVal.toUpperAscii}"""
    enumVals.add(val)
  result =
    &"""
    enum class {enumName} {{
        {enumVals.join(",\n        ")}
    }}"""

func translateProc(self: KotlinLangGen, node: PNode): string =
  var shouldWrap = false
  let funcName = procName(node)
  let paramNode = procParamNode(node)
  var retType = ""
  var trParamList, wrParamList, callableParamList: seq[string]
  if paramNode.isSome:
    let formalParamNode = paramNode.get()
    for i in 1 ..< formalParamNode.safeLen:
      let paramName = formalParamNode[i].paramName
      let paramType = formalParamNode[i].paramType
      let trParam = &"{paramName}: {paramType.replaceType}"
      var callableParam = paramName
      if self.typeCategory(paramType) == NamedTypeCategory.enumType:
        shouldWrap = true
        if wrParamList.len == 0:
          wrParamList = trParamList
        let wrapType = "Int" # Kotlin enum -> Int for JNI
        let wrParam = &"{paramName}: {wrapType}"
        wrParamList.add(wrParam)
        callableParam = &"{paramName}.ordinal"
      elif shouldWrap:
        let wrParam = trParam
        wrParamList.add(wrParam)
      trParamList.add(trParam)
      callableParamList.add(callableParam)
    if formalParamNode[0].kind != nkEmpty:
      retType = formalParamNode[0].ident.s
  let retTypePart =
    if retType == "":
      ""
    else:
      &": {retType.replaceType}"
  var wrRetType = retType
  var wrRetTypePart = retTypePart
  if self.typeCategory(retType) == NamedTypeCategory.enumType:
    shouldWrap = true
    wrRetType = "Int"
    wrRetTypePart = &": {wrRetType}"
  let trProc =
    &"""fun {funcName.startLowerCase}({trParamList.join(", ")}){retTypePart}"""
  let procCallStmt = &"""{funcName.wrapperFuncName}({callableParamList.join(", ")})"""
  let retBody =
    if wrRetType == "Int":
      &"""
        val data = {procCallStmt}
        return {retType}.values()[data]"""
    else:
      &"""
        {procCallStmt}"""
  result =
    if shouldWrap:
      &"""
    {trProc} {{
{retBody}
    }}

    external fun {funcName.wrapperFuncName}({wrParamList.join(", ")}){wrRetTypePart}"""
    else:
      &"""
    external {trProc}"""

func translateApi(self: KotlinLangGen, api: PNode): string =
  case api.kind
  of nkTypeDef:
    result = self.translateType(api)
  of nkProcDef, nkFuncDef, nkMethodDef:
    result = self.translateProc(api)
  else:
    result = "Cannot translate Api to Kotlin"

func generateKotlinWrapperContent(
    self: KotlinLangGen, bindingAST: seq[PNode], modName: string, libName: string
): string =
  var kotlinApis: seq[string]
  for api in bindingAST:
    let trApi = self.translateApi(api)
    kotlinApis.add(trApi)
  result =
    &"""
package {self.jvmPackageName}

class {modName.className} {{
{kotlinApis.join("\n\n")}

    companion object {{
        init {{
            System.loadLibrary("{libName}")
        }}
    }}
}}
"""

proc generateKotlinWrapper(self: KotlinLangGen, bindingAST: seq[PNode]) =
  let content =
    self.generateKotlinWrapperContent(bindingAST, moduleName, moduleName.jniLibName)
  if showVerboseOutput:
    styledEcho fgGreen, "Kotlin wrapper content:"
    echo content
  let wrapperFilePath = self.langDir / self.wrapperFileName
  self.ensureDir()
  wrapperFilePath.string.writeFile(content)

func getNimCompilationCommands(
    self: KotlinLangGen, androidCacheDirBase: string
): string =
  var cmds: seq[string]
  for (arch, _, _) in androidAbiArchArray:
    cmds.add &"""
    nim cpp -c -d:release --cpu:{arch} --os:android -d:androidNDK --noMain:on --app:staticlib --nimcache:{androidCacheDirBase}-{arch} {self.bindingModuleFile.string}"""
  return cmds.join("\n")

func getCppCompilationCommands(androidCacheDirBase: string): string =
  var cmds: seq[string]
  for (arch, _, target) in androidAbiArchArray:
    cmds.add &"""
    cd {androidCacheDirBase}-{arch}
    ~/Android/Sdk/ndk/27.0.12077973/toolchains/llvm/prebuilt/linux-x86_64/bin/clang++ -target {target}-linux-android24 -c -I ~/Applications/nim/lib -fPIC *.cpp
    cd .."""
  return cmds.join("\n")

func getArchiveCommands(libFileName: string, androidCacheDirBase: string): string =
  var cmds: seq[string]
  for (arch, abi, _) in androidAbiArchArray:
    cmds.add &"""
    mkdir {abi}
    ar r {abi}/{libFileName} {androidCacheDirBase}-{arch}/*.o
    rm -r {androidCacheDirBase}-{arch}"""
  return cmds.join("\n")

func moveLibCommands(self: KotlinLangGen): string =
  var cmds: seq[string]
  for (_, abi, _) in androidAbiArchArray:
    cmds.add &"""
    mv {abi}/ {self.cppModuleDir}/"""
  return cmds.join("\n")

method getReadMeContent(self: KotlinLangGen): string =
  let common = procCall self.BaseLangGen.getReadMeContent()
  let androidCacheDirBase = "androidCache"
  let libFileName = &"lib{moduleName}.a"
  result =
    &"""
{common}
Provide JVM Package Name in command line using the respective option.

#### Static Library
First, compile the nim code to C++ code for android with the following command.

{getNimCompilationCommands(self, androidCacheDirBase)}

Then compile the C++ code with proper android C++ compiler. You may find it as
`$ANDROID_HOME/ndk/$ndkVer/toolchains/llvm/prebuilt/$hostOS/bin/clang++`.
Provide the target architecture and minAndroidSdkVersion, e.g. aarch64-linux-android24.
Provide the directory of `"nimbase.h"` for include.
Provide all generated C++ files. It will generate .o files.

{getCppCompilationCommands(androidCacheDirBase)}

Archive the obj files to static libraries. Remove {androidCacheDirBase}-* directories, they aren't needed anymore.

{getArchiveCommands(libFileName, androidCacheDirBase)}

Copy this `{libFileName}` files to `{self.cppModuleDir.string}`.

{self.moveLibCommands}

Collect `{self.wrapperFileName.string}` and `cpp` folder from `{self.langDir.string}`.
Put them in the respective location inside your android project directory.
e.g. `cpp` folder should be in `$YourApp/app/src/main/cpp` and
`{self.wrapperFileName.string}` should be in `$YourApp/app/src/main/java/com/yourcompany/yourapp/{self.wrapperFileName.string}`

Open your Android Studio project and add the following to your `build.gradle.kts(:app)` file.
Since we are building only for ARM64, ABI filter is being set as such.

    ...
    android {{
        ...
        defaultConfig {{
            ...
        }}

        externalNativeBuild {{
            cmake {{
                path("src/main/cpp/CMakeLists.txt")
            }}
        }}
        ...
    }}
    ...

Now sync and build your project.

#### Dynamic Library
Not tested
"""

method generateBinding*(self: KotlinLangGen, bindingAST: seq[PNode]) =
  ## Generates binding & documentation for Kotlin
  self.generateKotlinWrapper(bindingAST)
  self.copyCppHeader()
  self.generateJNIWrapper(bindingAST)
  self.generateCMakeLists()
  self.generateReadMe()
