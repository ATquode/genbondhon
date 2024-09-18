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

proc testStaticLib(moduleName: string, outBinExec: string) =
  commonTasks()
  # compile nim lib
  let libCompileCmd =
    "nim cpp -d:release --noMain:on --app:staticlib --nimcache:cacheCppStatic --outdir:bindings/C++ bindings/nomuna.nim"
  executeTask("nim library compilation", libCompileCmd)
  # copy C++ header
  let copyHeaderCmd = "cp bindings/C++/nomuna.hpp tests/C++"
  executeTask("Copy header", copyHeaderCmd)
  # copy static lib
  let staticLibName =
    if defined(windows):
      "$#.lib".format(moduleName)
    else:
      "lib$#.a".format(moduleName)
  let copyLibCmd = "cp bindings/C++/$# tests/C++".format(staticLibName)
  executeTask("Copy lib binary", copyLibCmd)
  # compile C++ code, link with static lib
  let compileCppCmd = "g++ tests/C++/testCode.cpp tests/C++/$#".format(staticLibName)
  executeTask("Compile C++ code", compileCppCmd)
  # run C++ code output
  executeTask("Running a.out", outBinExec, outputToStd = true)

when isMainModule:
  let moduleName = "nomuna"
  let outBinExec = if defined(windows): ".\\a.exe" else: "./a.out"

  testStaticLib(moduleName, outBinExec)
