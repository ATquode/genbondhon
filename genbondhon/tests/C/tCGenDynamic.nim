# SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
#
# SPDX-License-Identifier: MIT

#!fmt: off
discard """
  output: '''
No Operation
extra: No Op.
2
1
2.300000
a
what
8
success
failure
8.080000
8.800000
a
nim
hello ñíℳ'''
"""
#!fmt: on

import std/strutils
import ../common

proc testDynamicLib(moduleName: string, outBinExec: string) =
  commonTasks()
  # compile nim lib
  let libCompileCmd =
    "nim c -d:release --noMain:on --app:lib --nimcache:cacheCDynamic --outdir:bindings/C bindings/nomuna.nim"
  executeTask("nim library compilation", libCompileCmd)
  # copy C header
  let copyHeaderCmd = "cp bindings/C/nomuna.h tests/C"
  executeTask("Copy header", copyHeaderCmd)
  # copy dynamic lib
  let dynamicLibName =
    if defined(windows):
      "$#.dll".format(moduleName)
    elif defined(macosx):
      "lib$#.dylib".format(moduleName)
    else:
      "lib$#.so".format(moduleName)
  let copyLibCmd = "cp bindings/C/$# tests/C".format(dynamicLibName)
  executeTask("Copy lib binary", copyLibCmd)
  # compile C code, link with dynamic lib
  let compileCCmd = "gcc tests/C/testCode.c tests/C/$#".format(dynamicLibName)
  executeTask("Compile C code", compileCCmd)
  # copy dll to pwd on windows
  if defined(windows):
    let copyDllCmd = "cp tests/C/$# .".format(dynamicLibName)
    executeTask("Copy dll to pwd", copyDllCmd)
  # run C code output
  executeTask("Running a.out", outBinExec, outputToStd = true)

when isMainModule:
  let moduleName = "nomuna"
  let outBinExec = if defined(windows): ".\\a.exe" else: "./a.out"

  testDynamicLib(moduleName, outBinExec)
