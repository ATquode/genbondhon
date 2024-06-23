# SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
#
# SPDX-License-Identifier: MIT

import std/strutils

var fromOutside = false
var cwd = getCurrentDir()
var pathPart = "genbondhon/genbondhon"
if defined(windows):
  pathPart = "genbondhon\\genbondhon"
if pathPart notin cwd:
  fromOutside = true
  cwd = cwd & "/genbondhon"

task dev, "build and run in debug mode":
  var passParam = ""
  if paramCount() > 1:
    for i in 2 .. paramCount():
      passParam.add(" " & paramStr(i))
  exec "nim c -r --outdir:" & cwd & " " & cwd & "/src/genbondhon.nim" & passParam

task build, "build in release mode and put into dist folder":
  exec "nim c -d:release --outdir:" & cwd & "/dist " & cwd & "/src/genbondhon.nim"

task test, "run tests":
  const execTest = "testament all"
  if fromOutside:
    withDir "genbondhon":
      exec execTest
  else:
    exec execTest

task clean, "clean artifacts":
  exec "git clean -fdX"
