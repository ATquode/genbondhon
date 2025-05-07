#!/usr/bin/env nimcr

# SPDX-FileCopyrightText: 2025 Rifat Hasan <atunutemp1@gmail.com>
#
# SPDX-License-Identifier: MIT

import std/[osproc, strutils, terminal]

# command names
const reuse = "reuse"
const nph = "nph"
const ktlint = "ktlint"
const detekt = "detekt"

const detektBin = if defined(linux): "detekt-cli" else: "detekt"

# format commands
const nphFormatCmd = "nph ."
const ktlintFormatCmd = "ktlint --format"
const detektFormatCmd = detektBin & " --config detekt-config.yml --auto-correct"

# lint commands
const reuseLintCmd = "reuse lint"
const nphLintCmd = "nph --check ."
const ktlintLintCmd = "ktlint"
const detektLintCmd = detektBin & " --config detekt-config.yml"

proc runCmd(cmdName: string, cmdType: string, cmdStr: string): bool =
  styledEcho fgYellow, "Running $# $#" % [cmdName, cmdType]
  let cmd =
    if defined(windows):
      "powershell.exe " & cmdStr
    else:
      cmdStr
  let (cmdOutput, cmdRes) = execCmdEx(cmd)
  echo cmdOutput
  result = cmdRes == 0
  if result:
    styledEcho fgGreen, "$# $# successful\n" % [cmdName, cmdType]
  else:
    styledEcho fgRed, "$# $# failed\n" % [cmdName, cmdType]

proc format(): bool =
  const cmdTypeFmt = "format"
  # nph
  let nphFmtRes = runCmd(nph, cmdTypeFmt, nphFormatCmd)
  # ktlint
  let ktlintFmtRes = runCmd(ktlint, cmdTypeFmt, ktlintFormatCmd)
  # detekt
  let detektFmtRes = runCmd(detekt, cmdTypeFmt, detektFormatCmd)

  return nphFmtRes and ktlintFmtRes and detektFmtRes

proc lint(): bool =
  const cmdTypeLint = "lint"
  # reuse
  let reuseLintRes = runCmd(reuse, cmdTypeLint, reuseLintCmd)
  # nph
  let nphLintRes = runCmd(nph, cmdTypeLint, nphLintCmd)
  # ktlint
  let ktlintLintRes = runCmd(ktlint, cmdTypeLint, ktlintLintCmd)
  # detekt
  let detektLintRes = runCmd(detekt, cmdTypeLint, detektLintCmd)

  return reuseLintRes and nphLintRes and ktlintLintRes and detektLintRes

when isMainModule:
  # format
  styledEcho styleBright, "### Formatting..."
  let formatRes = format()
  if formatRes:
    styledEcho styleBright, fgGreen, "Format Successful"
  else:
    styledEcho styleBright, fgRed, "Format Failure"
  echo ""
  # lint
  styledEcho styleBright, "### Linting..."
  let lintResult = lint()
  if lintResult:
    styledEcho styleBright, fgGreen, "Lint Successful"
  else:
    styledEcho styleBright, fgRed, "Lint Failure"

  echo "\n"
  let totalRes = formatRes and lintResult
  if totalRes:
    styledEcho styleBright, fgGreen, "## Success"
  else:
    styledEcho styleBright, fgRed, "## Failure"
