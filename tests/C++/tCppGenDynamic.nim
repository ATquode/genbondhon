# SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
#
# SPDX-License-Identifier: MIT

#!fmt: off
discard """
  output: '''
1
2
2.3
8
8.08
8.8
Game State: 102
Game State: 102
Hello World!
Héllø ñíℳ
No Operation
Opposite of North: expected 2, got 2
a
a
direction raw value: 2
extra: No Op.
failure
hello ñíℳ
nim
success
what
প্রোগ্রামিং'''
  sortoutput: true
"""
#!fmt: on

import std/strutils
import ../common

proc testDynamicLib(moduleName: string, outFile: string) =
  # compile nim lib
  let libCompileCmd =
    "nim cpp -d:release --noMain:on --app:lib --nimcache:cacheCppDynamic --outdir:bindings/C++ bindings/nomuna.nim"
  executeTask("nim library compilation", libCompileCmd)
  # copy C++ header
  let copyHeaderCmd = "cp bindings/C++/nomuna.hpp tests/C++"
  executeTask("Copy header", copyHeaderCmd)
  # copy dynamic lib
  let dynamicLibName =
    if defined(windows):
      "$#.dll".format(moduleName)
    elif defined(macosx):
      "lib$#.dylib".format(moduleName)
    else:
      "lib$#.so".format(moduleName)
  let copyLibCmd = "cp bindings/C++/$# tests/C++".format(dynamicLibName)
  executeTask("Copy lib binary", copyLibCmd)
  # compile C++ code, link with dynamic lib
  let compileCppCmd =
    "g++ tests/C++/testCode.cpp tests/C++/$# -o $#".format(dynamicLibName, outFile)
  executeTask("Compile C++ code", compileCppCmd)
  # copy binary to test dir on windows
  if defined(windows):
    let copyBinCmd = "cp $# tests/C++/".format(outFile)
    executeTask("Copy $# to test dir".format(outFile), copyBinCmd)
  # run C++ code output
  let outBinExec =
    if defined(windows):
      ".\\tests\\C++\\$#".format(outFile)
    else:
      "./$#".format(outFile)
  executeTask("Running $#".format(outFile), outBinExec, outputToStd = true)

when isMainModule:
  let moduleName = "nomuna"
  let outName = "aCppDyn"
  let outFileName =
    if defined(windows):
      "$#.exe".format(outName)
    else:
      "$#.out".format(outName)

  testDynamicLib(moduleName, outFileName)
