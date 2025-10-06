#!/usr/bin/env nimcr

# SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
#
# SPDX-License-Identifier: MIT

import std/[osproc, strutils, terminal]

# command names
const reuse = "reuse"
const nph = "nph"
const csharpier = "CSharpier"
const xamlstyler = "XamlStyler"

# format commands
const nphFormatCmd = "nph ."
const csharpierFormatCmd = "dotnet csharpier format ."
const xamlstylerFormatCmd = "dotnet xstyler -r -d ."

# lint commands
const reuseLintCmd = "reuse lint"
const nphLintCmd = "nph --check ."
const csharpierLintCmd = "dotnet csharpier check ."
const xamlstylerLintCmd = "dotnet xstyler -p -r -d ."

proc runCmd(cmdName: string, cmdType: string, cmd: string): bool =
  styledEcho fgYellow, "Running $# $#" % [cmdName, cmdType]
  let (cmdOutput, cmdRes) = execCmdEx(cmd)
  echo cmdOutput
  result = cmdRes == 0
  if result:
    styledEcho fgGreen, "$# $# successful\n" % [cmdName, cmdType]
  else:
    styledEcho fgRed, "$# $# failed\n" % [cmdName, cmdType]
    if cmd.startsWith("dotnet"):
      styledEcho styleBright, fgBlue, "** Please run `dotnet tool restore` **\n"

proc format(): bool =
  const cmdTypeFmt = "format"
  # nph
  let nphFmtRes = runCmd(nph, cmdTypeFmt, nphFormatCmd)
  # csharpier
  let csharpierFmtRes = runCmd(csharpier, cmdTypeFmt, csharpierFormatCmd)
  # xamlstyler
  let xamlstylerFmtRes = runCmd(xamlstyler, cmdTypeFmt, xamlstylerFormatCmd)

  return nphFmtRes and csharpierFmtRes and xamlstylerFmtRes

proc lint(): bool =
  const cmdTypeLint = "lint"
  # reuse
  let reuseLintRes = runCmd(reuse, cmdTypeLint, reuseLintCmd)
  # nph
  let nphLintRes = runCmd(nph, cmdTypeLint, nphLintCmd)
  # csharpier
  let csharpierLintRes = runCmd(csharpier, cmdTypeLint, csharpierLintCmd)
  # xamlstyler
  let xamlstylerLintRes = runCmd(xamlstyler, cmdTypeLint, xamlstylerLintCmd)

  return reuseLintRes and nphLintRes and csharpierLintRes and xamlstylerLintRes

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
