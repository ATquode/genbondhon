# SPDX-FileCopyrightText: 2025 Rifat Hasan <atunutemp1@gmail.com>
#
# SPDX-License-Identifier: MIT

import std/[dirs, paths, strformat]
import ../common

proc testBuildingMyApp(moduleName: string) =
  # generate c code
  let iosCacheDir = "iosCache"
  let compileToCCmd =
    &"nim c -c -d:release --os:ios --noMain:on --app:staticLib --nimcache: {iosCacheDir} bindings/nomuna.nim"
  executeTask("nim compilation to C", compileToCCmd)
  # compile to obj files
  let compileToObjFilex64Cmd =
    &"xcrun -sdk iphonesimulator clang -c -arch x86_64 -I {findNimStdLib()} *.c"
  executeTask(
    "c compilation to obj file", compileToObjFilex64Cmd, workingDir = iosCacheDir
  )
  # archive to static lib
  let archiveToLibx64Cmd = "ar r libnomuna-x64.a iosCache/*.o"
  executeTask("archive to lib", archiveToLibx64Cmd)
  let rmObjCmd = "rm iosCache/*.o"
  executeTask("remove obj files", rmObjCmd)
  # compile to obj files
  let compileToObjFilearm64Cmd =
    &"xcrun -sdk iphonesimulator clang -c -arch arm64 -I {findNimStdLib()} *.c"
  executeTask(
    "c compilation to obj file", compileToObjFilearm64Cmd, workingDir = iosCacheDir
  )
  # archive to static lib
  let archiveToLibarm64Cmd = "ar r libnomuna-arm64.a iosCache/*.o"
  executeTask("archive to lib", archiveToLibarm64Cmd)
  # merge libs
  let mergeLibsCmd =
    "lipo -create -output libnomuna.a libnomuna-x64.a libnomuna-arm64.a"
  executeTask("create fat binary", mergeLibsCmd)
  # copy static lib to binding dir
  let iosBindingDir = "bindings/Swift/iOS"
  if not iosBindingDir.Path.dirExists:
    let createIosDirCmd = &"mkdir {iosBindingDir}"
    executeTask("create iOS binding dir", createIosDirCmd)
  let copyLibCmdToBinding = &"cp libnomuna.a {iosBindingDir}"
  executeTask("Copy static lib to binding dir", copyLibCmdToBinding)
  # copy Swift wrapper
  let myAppDir = "tests/Swift/iOS/MyApp1"
  let copyCModuleCmd = &"cp -r bindings/Swift/CNomuna {myAppDir}/MyApp1/CNomuna"
  executeTask("Copy CModule", copyCModuleCmd)
  # copy static lib
  let copyLibCmd = &"cp bindings/Swift/iOS/libnomuna.a {myAppDir}/MyApp1/CNomuna"
  executeTask("Copy lib binary", copyLibCmd)
  # build project
  let xcodeBuildCmd =
    """xcodebuild -project MyApp1.xcodeproj/ -scheme MyApp1 -destination "generic/platform=iOS Simulator" -configuration Debug"""
  executeTask("Build Project", xcodeBuildCmd, workingDir = myAppDir)

when isMainModule:
  let moduleName = "nomuna"

  testBuildingMyApp(moduleName)
