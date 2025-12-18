# SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
#
# SPDX-License-Identifier: MIT

#!fmt: off
discard """
  output:'''
No Operation
extra: No Op.
2
true
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
Opposite of north: expected south, got south
Direction: south, value: 2
Game State: game_over, value: 102
Game State: game_over, value: 102
Status code: unauthorized, value: 401
set Game State result: bad_request, value: 400
admin has permission value: 0x02
Least priviledged permission value: 0x01'''
  disabled: windows
  disabled: linux
"""
#!fmt: on

import std/[osproc, strformat, strutils]
import ../common

proc getBuildDir(projectPath: string, buildCmd: string): string =
  let targetBuildDirCmd = &"{buildCmd} -showBuildSettings | grep TARGET_BUILD_DIR"
  let (grepOutput, exitCode) = execCmdEx(targetBuildDirCmd, workingDir = projectPath)
  assert exitCode == 0, "Finding build Dir Failed, code: $#".format(exitCode)
  let buildDir = grepOutput.split('=')[^1].strip
  return buildDir

proc testCommandLineTool(moduleName: string) =
  # compile nim lib
  let libCompileCmd =
    "nim c -d:release --noMain:on --app:staticlib --nimcache:cacheSwift --outdir:bindings/Swift/macOS bindings/nomuna.nim"
  executeTask("nim library compilation", libCompileCmd)
  # copy Swift wrapper
  let commandLineToolDir = "tests/Swift/macOS/CommandLineTool1"
  let copyCModuleCmd =
    "cp -r bindings/Swift/CNomuna " & commandLineToolDir & "/CommandLineTool1/"
  executeTask("Copy CModule", copyCModuleCmd)
  # copy static lib
  let copyLibCmd =
    "cp bindings/Swift/macOS/libnomuna.a " & commandLineToolDir &
    "/CommandLineTool1/CNomuna/"
  executeTask("Copy lib binary", copyLibCmd)
  # build project
  let xcodeBuildCmd =
    """xcodebuild -project CommandLineTool1.xcodeproj/ -scheme CommandLineTool1 -destination "name=My Mac" -configuration Debug"""
  executeTask("Build Project", xcodeBuildCmd, workingDir = commandLineToolDir)
  # run project
  let productDir = getBuildDir(commandLineToolDir, xcodeBuildCmd)
  let runCmd = productDir & "/CommandLineTool1"
  executeTask("Run Project", runCmd, outputToStd = true)

when isMainModule:
  let moduleName = "nomuna"

  testCommandLineTool(moduleName)
