# SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
#
# SPDX-License-Identifier: MIT

#!fmt: off
discard """
  output:'''
No Operation
extra: No Op.
2
True
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
Héllø ñíℳ
Hello World!
direction raw value: 2
Opposite of North: expected South, got South
Direction: South, value: 2
Game State: Game_over, value: 102
Game State: Game_over, value: 102
Status code: Unauthorized, value: 401
set Game State result: Bad_request, value: 400'''
  disabled: unix
"""
#!fmt: on

import ../common

proc testConsoleApp(moduleName: string) =
  # compile nim lib
  let libCompileCmd =
    "nim c --cc:vcc -d:release --noMain:on --app:lib --nimcache:cacheC# --outdir:bindings/C# bindings/nomuna.nim"
  executeTask("nim library compilation", libCompileCmd)
  # copy C# wrapper
  let consoleAppDir = "tests/C#/ConsoleApp1"
  let copyWrapperCmd = "cp bindings/C#/nomuna.cs " & consoleAppDir
  executeTask("Copy wrapper", copyWrapperCmd)
  # copy dynamic lib
  let copyLibCmd = "cp bindings/C#/nomuna.dll " & consoleAppDir
  executeTask("Copy lib binary", copyLibCmd)
  # build & run project
  let netRunCmd = "dotnet run"
  executeTask(
    "Build & run Project", netRunCmd, outputToStd = true, workingDir = consoleAppDir
  )

when isMainModule:
  let moduleName = "nomuna"

  testConsoleApp(moduleName)
