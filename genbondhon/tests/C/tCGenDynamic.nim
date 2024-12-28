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
প্রোগ্রামিং
8
success
failure
8.080000
8.800000
a
nim
hello ñíℳ
Héllø ñíℳ'''
"""
#!fmt: on

import std/strutils
import ../common

proc testDynamicLib(moduleName: string, outFile: string) =
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
  let compileCCmd =
    "gcc tests/C/testCode.c tests/C/$# -o $#".format(dynamicLibName, outFile)
  executeTask("Compile C code", compileCCmd)
  # copy binary to test dir on windows
  if defined(windows):
    let copyBinCmd = "cp $# tests/C/".format(outFile)
    executeTask("Copy $# to test dir".format(outFile), copyBinCmd)
  # run C code output
  let outBinExec =
    if defined(windows):
      ".\\tests\\C\\$#".format(outFile)
    else:
      "./$#".format(outFile)
  executeTask("Running $#".format(outFile), outBinExec, outputToStd = true)

when isMainModule:
  let moduleName = "nomuna"
  let outName = "aCDyn"
  let outFileName =
    if defined(windows):
      "$#.exe".format(outName)
    else:
      "$#.out".format(outName)

  testDynamicLib(moduleName, outFileName)
