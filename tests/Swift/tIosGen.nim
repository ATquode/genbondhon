# SPDX-FileCopyrightText: 2025 Rifat Hasan <atunutemp1@gmail.com>
#
# SPDX-License-Identifier: MIT

#!fmt: off
discard """
  disabled: windows
  disabled: linux
"""
#!fmt: on

import std/[dirs, paths, strformat, strutils]
import ../common

proc testBuildingMyApp(moduleName: string) =
  # generate c code
  let iosCacheDir = "iosCache"
  let tempIosDir = "iOS"
  let tempIosSimulatorDir = "iOSSimulator"
  let libName = "lib$#.a".format(moduleName)
  let libx64 = "lib$#-x64.a".format(moduleName)
  let libarm64 = "lib$#-arm64.a".format(moduleName)
  let compileToCCmd =
    &"nim c -c -d:release --os:ios --noMain:on --app:staticLib --nimcache: {iosCacheDir} bindings/nomuna.nim"
  executeTask("nim compilation to C", compileToCCmd)
  # compile to obj files
  let compileToObjFileIosCmd =
    &"xcrun -sdk iphoneos clang -c -arch arm64 -I {findNimStdLib()} *.c"
  executeTask(
    "c compilation to obj file for arm64 device",
    compileToObjFileIosCmd,
    workingDir = iosCacheDir,
  )
  # archive to static lib
  createDir(tempIosDir.Path)
  let archiveToLibIosCmd = &"ar r {tempIosDir}/{libName} {iosCacheDir}/*.o"
  executeTask("archive to lib", archiveToLibIosCmd)
  let rmObjCmd = &"rm {iosCacheDir}/*.o"
  executeTask("remove obj files", rmObjCmd)
  # compile to obj files
  let compileToObjFilex64Cmd =
    &"xcrun -sdk iphonesimulator clang -c -arch x86_64 -I {findNimStdLib()} *.c"
  executeTask(
    "c compilation to obj file for x64 simulator",
    compileToObjFilex64Cmd,
    workingDir = iosCacheDir,
  )
  # archive to static lib
  createDir(tempIosSimulatorDir.Path)
  let archiveToLibx64Cmd = &"ar r {tempIosSimulatorDir}/{libx64} {iosCacheDir}/*.o"
  executeTask("archive to lib", archiveToLibx64Cmd)
  executeTask("remove obj files", rmObjCmd)
  # compile to obj files
  let compileToObjFilearm64Cmd =
    &"xcrun -sdk iphonesimulator clang -c -arch arm64 -I {findNimStdLib()} *.c"
  executeTask(
    "c compilation to obj file for arm64 simulator",
    compileToObjFilearm64Cmd,
    workingDir = iosCacheDir,
  )
  # archive to static lib
  let archiveToLibarm64Cmd = &"ar r {tempIosSimulatorDir}/{libarm64} {iosCacheDir}/*.o"
  executeTask("archive to lib", archiveToLibarm64Cmd)
  # merge libs
  let mergeLibsCmd =
    &"lipo -create -output {tempIosSimulatorDir}/{libName} {tempIosSimulatorDir}/{libx64} {tempIosSimulatorDir}/{libarm64}"
  executeTask("create fat binary", mergeLibsCmd)
  # create xcframework
  let iosBindingDir = "bindings/Swift/iOS"
  let cModuleDir = "bindings/Swift/CNomuna"
  let xcframeworkPath = "$#/lib$#.xcframework".format(iosBindingDir, moduleName).Path
  if dirExists(xcframeworkPath):
    removeDir(xcframeworkPath)
  let createXcframeworkCmd =
    &"xcodebuild -create-xcframework -library {tempIosDir}/{libName} -headers {cModuleDir}/nomuna.h -library {tempIosSimulatorDir}/{libName} -headers {cModuleDir}/nomuna.h -output {xcframeworkPath.string}"
  executeTask("create xcframework", createXcframeworkCmd)
  # copy Swift wrapper
  let myAppDir = "tests/Swift/iOS/MyApp1"
  let copyCModuleCmd = &"cp -r {cModuleDir} {myAppDir}/MyApp1/"
  executeTask("Copy CModule", copyCModuleCmd)
  # copy xcframework
  let copyLibCmd = &"cp -r {xcframeworkPath.string} {myAppDir}/MyApp1/CNomuna/"
  executeTask("Copy lib binary", copyLibCmd)
  # build project
  let xcodeBuildCmd =
    """xcodebuild -project MyApp1.xcodeproj/ -scheme MyApp1 -destination "generic/platform=iOS Simulator" -configuration Debug"""
  executeTask("Build Project", xcodeBuildCmd, workingDir = myAppDir)

when isMainModule:
  let moduleName = "nomuna"

  testBuildingMyApp(moduleName)
