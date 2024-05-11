# SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
#
# SPDX-License-Identifier: MIT

import std/strutils

var cwd = getCurrentDir()
var pathPart = "genbondhon/genbondhon"
if defined(windows):
  pathPart = "genbondhon\\genbondhon"
if pathPart notin cwd:
  cwd = cwd & "/genbondhon"

task dev, "build and run in debug mode":
  exec "nim c -r --outdir:" & cwd & " " & cwd & "/src/genbondhon.nim"

task dist, "build in release mode and put into dist folder":
  exec "nim c -d:release --outdir:" & cwd & "/dist " & cwd & "/src/genbondhon.nim"
