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

proc testStaticLib(moduleName: string, outFile: string) =
  # compile nim lib
  let libCompileCmd =
    "nim c -d:release --noMain:on --app:staticlib --nimcache:cacheCStatic --outdir:bindings/C bindings/nomuna.nim"
  executeTask("nim library compilation", libCompileCmd)
  # copy C header
  let copyHeaderCmd = "cp bindings/C/nomuna.h tests/C"
  executeTask("Copy header", copyHeaderCmd)
  # copy static lib
  let staticLibName =
    if defined(windows):
      "$#.lib".format(moduleName)
    else:
      "lib$#.a".format(moduleName)
  let copyLibCmd = "cp bindings/C/$# tests/C".format(staticLibName)
  executeTask("Copy lib binary", copyLibCmd)
  # compile C code, link with static lib
  let compileCCmd =
    "gcc tests/C/testCode.c tests/C/$# -o $#".format(staticLibName, outFile)
  executeTask("Compile C code", compileCCmd)
  # run C code output
  let outBinExec =
    if defined(windows):
      ".\\$#".format(outFile)
    else:
      "./$#".format(outFile)
  executeTask("Running $#".format(outFile), outBinExec, outputToStd = true)

when isMainModule:
  let moduleName = "nomuna"
  let outName = "aCStat"
  let outFileName =
    if defined(windows):
      "$#.exe".format(outName)
    else:
      "$#.out".format(outName)

  testStaticLib(moduleName, outFileName)
