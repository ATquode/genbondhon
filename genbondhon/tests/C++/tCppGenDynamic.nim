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
2.3
a
what
প্রোগ্রামিং
8
success
failure
8.08
8.8
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
  var copyLibCmd = "cp bindings/C++/$# tests/C++".format(dynamicLibName)
  let newDllName = "Cpp$#".format(dynamicLibName)
  if defined(windows):
    copyLibCmd = copyLibCmd & "/$#".format(newDllName)
  executeTask("Copy lib binary", copyLibCmd)
  # compile C++ code, link with dynamic lib
  let compileCppCmd =
    "g++ tests/C++/testCode.cpp tests/C++/$# -o $#".format(dynamicLibName, outFile)
  executeTask("Compile C++ code", compileCppCmd)
  # copy dll to pwd on windows
  if defined(windows):
    let copyDllCmd = "cp tests/C++/$# .".format(newDllName)
    executeTask("Copy dll to pwd", copyDllCmd)
  # run C++ code output
  let outBinExec =
    if defined(windows):
      ".\\$#".format(outFile)
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
