# SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
#
# SPDX-License-Identifier: MIT

import std/[algorithm, dirs, os, paths, sequtils, strformat, strutils]
import ../common

proc NDKPath(appRootDir: string): string =
  let localPropFile = appRootDir & "/local.properties"
  let contents = readFile(localPropFile)
  let sdkDirStart = contents.find("sdk.dir")
  var sdkDirEnd = contents.find(Newlines, start = sdkDirStart)
  if sdkDirEnd == -1:
    sdkDirEnd = contents.len
  let sdkDirLine = contents[sdkDirStart ..< sdkDirEnd]
  let sdkDirLineParts = sdkDirLine.split('=')
  let sdkDirLocation = sdkDirLineParts[^1]
  let ndkDirs = toSeq(walkDir(Path(sdkDirLocation & "/ndk"), relative = true))
    .filterIt(it.kind == pcDir)
    .mapIt(it.path.splitPath[1].string)
    .sorted(SortOrder.Descending)
  let latestNdkDir = ndkDirs[0]
  return sdkDirLocation & "/ndk/" & latestNdkDir

func getHostCPU(): string =
  if hostCPU == "amd64": "x86_64" else: hostCPU

proc findNimStdLib(): string =
  ## Tries to find a path to a valid "system.nim" file.
  ## Returns "" on failure.
  try:
    let nimexe = os.findExe("nim")
      # this can't work with choosenim shims, refs https://github.com/dom96/choosenim/issues/189
      # it'd need `nim dump --dump.format:json . | jq -r .libpath`
      # which we should simplify as `nim dump --key:libpath`
    if nimexe.len == 0:
      return ""
    result = nimexe.splitPath()[0] /../ "lib"
    if not fileExists(result / "system.nim"):
      when defined(unix):
        result = nimexe.expandSymlink.splitPath()[0] /../ "lib"
        if not fileExists(result / "system.nim"):
          return ""
  except OSError, ValueError:
    return ""

proc testBuildingApp(moduleName: string) =
  commonTasks()
  let androidCacheDir = "androidCache"
  # generate cpp code
  let compileCmd =
    &"nim cpp -c -d:release --cpu:arm64 --os:android -d:androidNDK --noMain:on --app:staticlib --nimcache:{androidCacheDir} bindings/nomuna.nim"
  executeTask("generate cpp code from nim code", compileCmd)
  # compile to object files
  let myApplicationDir = "tests/Kotlin/MyApplication1"
  let libCompileCmd =
    &"{myApplicationDir.NDKPath}/toolchains/llvm/prebuilt/{hostOS}-{getHostCPU()}/bin/clang++ -target aarch64-linux-android24 -c -I {findNimStdLib()} -fPIC *.cpp"
  executeTask(
    "compiling cpp code to object files", libCompileCmd, workingDir = androidCacheDir
  )
  # archive object files to static lib
  let archiveCmd = &"ar r bindings/Kotlin/cpp/lib{moduleName}.a {androidCacheDir}/*.o"
  executeTask("archive object files to static lib", archiveCmd)
  # copy Kotlin JNI wrapper
  let mainBuildFlavorDir = &"{myApplicationDir}/app/src/main"
  let copyCppModuleCmd = &"cp -r bindings/Kotlin/cpp {mainBuildFlavorDir}/cpp"
  executeTask("Copy CModule", copyCppModuleCmd)
  let copyKotlinWrapperCmd =
    &"cp -r bindings/Kotlin/Nomuna.kt {mainBuildFlavorDir}/java/com/example/myapplication1/"
  executeTask("Copy Kotlin wrapper", copyKotlinWrapperCmd)
  # build project
  let gradleBuildCmd = "./gradlew assembleDebug"
  executeTask("Build Project", gradleBuildCmd, workingDir = myApplicationDir)

when isMainModule:
  let moduleName = "nomuna"

  testBuildingApp(moduleName)
