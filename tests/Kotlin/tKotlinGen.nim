# SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
#
# SPDX-License-Identifier: MIT

import std/[algorithm, dirs, files, os, paths, sequtils, strformat, strutils]
import ../common

proc sdkDirFromLocalPropFile(localPropFile: Path): Path =
  let contents = readFile(localPropFile.string)
  let sdkDirStart = contents.find("sdk.dir")
  var sdkDirEnd = contents.find(Newlines, start = sdkDirStart)
  if sdkDirEnd == -1:
    sdkDirEnd = contents.len
  let sdkDirLine = contents[sdkDirStart ..< sdkDirEnd]
  let sdkDirLineParts = sdkDirLine.split('=')
  let sdkDirLocation = sdkDirLineParts[^1].multiReplace([("C\\:", "C:"), ("\\\\", "/")])
  return sdkDirLocation.Path

proc NDKPath(appRootDir: Path): Path =
  let localPropFile = appRootDir / "local.properties".Path
  var sdkDirLocation: Path
  const androidHomeEnv = "ANDROID_HOME"
  if localPropFile.fileExists():
    sdkDirLocation = sdkDirFromLocalPropFile(localPropFile)
  elif existsEnv(androidHomeEnv):
    sdkDirLocation = getEnv(androidHomeEnv).Path
  else:
    assert false,
      "Could not determine Android SDK dir. Provide local.properties or $# Env var".format(
        androidHomeEnv
      )
  let ndkDirs = toSeq(walkDir(sdkDirLocation / "ndk".Path, relative = true))
    .filterIt(it.kind == pcDir)
    .mapIt(it.path.splitPath[1].string)
    .sorted(SortOrder.Descending)
  let latestNdkDir = ndkDirs[0].Path
  return sdkDirLocation / "ndk".Path / latestNdkDir

func getHostOS(): string =
  if defined(macosx): "darwin" else: hostOS

proc testBuildingApp(moduleName: string) =
  let androidCacheDirBase = "androidCache"
  # generate cpp code
  const archs = ["arm64", "arm", "i386", "amd64"]
  for arch in archs:
    let compileCmd =
      &"nim cpp -c -d:release --cpu:{arch} --os:android -d:androidNDK --noMain:on --app:staticlib --nimcache:{androidCacheDirBase}-{arch} bindings/nomuna.nim"
    executeTask("generate cpp code from nim code for " & arch, compileCmd)
  # compile to object files
  let myApplicationDir = "tests/Kotlin/MyApplication1".Path
  let clangExe = if defined(windows): "clang++.exe" else: "clang++"
  const targets = ["aarch64", "armv7a", "i686", "x86_64"]
  for i in 0 ..< targets.len:
    let libCompileCmd =
      &"{myApplicationDir.NDKPath.string}/toolchains/llvm/prebuilt/{getHostOS()}-x86_64/bin/{clangExe} -target {targets[i]}-linux-android24 -c -I {findNimStdLib()} -fPIC *.cpp"
    executeTask(
      "compiling cpp code to object files for " & targets[i],
      libCompileCmd,
      workingDir = androidCacheDirBase & "-" & archs[i],
    )
  # archive object files to static lib
  const abis = ["arm64-v8a", "armeabi-v7a", "x86", "x86_64"]
  for i in 0 ..< abis.len:
    createDir(Path("bindings/Kotlin/cpp/" & abis[i]))
    let archiveCmd =
      &"ar r bindings/Kotlin/cpp/{abis[i]}/lib{moduleName}.a {androidCacheDirBase}-{archs[i]}/*.o"
    executeTask("archive object files to static lib for " & abis[i], archiveCmd)
  # copy Kotlin JNI wrapper
  let mainBuildFlavorDir = &"{myApplicationDir.string}/app/src/main"
  var copyCppModuleCmd = &"cp -r bindings/Kotlin/cpp {mainBuildFlavorDir}/"
  when defined(windows):
    copyCppModuleCmd = copyCppModuleCmd & " -fo"
  executeTask("Copy CppModule", copyCppModuleCmd)
  let copyKotlinWrapperCmd =
    &"cp -r bindings/Kotlin/Nomuna.kt {mainBuildFlavorDir}/java/com/example/myapplication1/"
  executeTask("Copy Kotlin wrapper", copyKotlinWrapperCmd)
  # build project
  let gradlew = if defined(windows): "gradlew.bat" else: "gradlew"
  let gradleBuildCmd = &"./{gradlew} assembleDebug"
  executeTask("Build Project", gradleBuildCmd, workingDir = myApplicationDir.string)

when isMainModule:
  let moduleName = "nomuna"

  testBuildingApp(moduleName)
