#!/usr/bin/env nimcr

# SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
#
# SPDX-License-Identifier: MIT

import std/[osproc, terminal]

const reuseLintCmd = "reuse lint"

proc lint(): bool =
  styledEcho fgYellow, "Running reuse lint"
  let (reuseLintOutput, reuseLintRes) = execCmdEx(reuseLintCmd)
  echo reuseLintOutput
  result = reuseLintRes == 0
  if result:
    styledEcho fgGreen, "reuse lint successful\n"
  else:
    styledEcho fgRed, "reuse lint failed\n"

when isMainModule:
  let lintResult = lint()
  if lintResult:
    styledEcho styleBright, fgGreen, "Lint Successful"
  else:
    styledEcho styleBright, fgRed, "Lint Failure"
