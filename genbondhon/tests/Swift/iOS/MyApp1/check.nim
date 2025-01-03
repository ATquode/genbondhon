#!/usr/bin/env nimcr

# SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
#
# SPDX-License-Identifier: MIT

import std/[osproc, strutils, terminal]

# command names
const reuse = "reuse"
const nph = "nph"
const swiftformat = "SwiftFormat"
const swiftlint = "SwiftLint"

# format commands
const nphFormatCmd = "nph ."
const swiftformatFormatCmd = "swiftformat ."
const swiftlintFixCmd = "swiftlint --fix ."

# lint commands
const reuseLintCmd = "reuse lint"
const nphLintCmd = "nph --check ."
const swiftformatLintCmd = "swiftformat --lint ."
const swiftlintLintCmd = "swiftlint ."

proc runCmd(cmdName: string, cmdType: string, cmd: string): bool =
  styledEcho fgYellow, "Running $# $#" % [cmdName, cmdType]
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
  # swiftformat
  let swiftformatFmtRes = runCmd(swiftformat, cmdTypeFmt, swiftformatFormatCmd)
  # swiftlint
  let swiftlintFmtRes = runCmd(swiftlint, cmdTypeFmt, swiftlintFixCmd)

  return nphFmtRes and swiftformatFmtRes and swiftlintFmtRes

proc lint(): bool =
  const cmdTypeLint = "lint"
  # reuse
  let reuseLintRes = runCmd(reuse, cmdTypeLint, reuseLintCmd)
  # nph
  let nphLintRes = runCmd(nph, cmdTypeLint, nphLintCmd)
  # swiftformat
  let swiftformatLintRes = runCmd(swiftformat, cmdTypeLint, swiftformatLintCmd)
  # swiftlint
  let swiftlintLintRes = runCmd(swiftlint, cmdTypeLint, swiftlintLintCmd)

  return reuseLintRes and nphLintRes and swiftformatLintRes and swiftlintLintRes

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
