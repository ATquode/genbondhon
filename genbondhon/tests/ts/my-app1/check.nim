#!/usr/bin/env nimcr

# SPDX-FileCopyrightText: 2025 Rifat Hasan <atunutemp1@gmail.com>
#
# SPDX-License-Identifier: MIT

import std/[osproc, strutils, terminal]

# command names
const reuse = "reuse"
const nph = "nph"
const prettier = "prettier"
const eslint = "eslint"
const svelteCheck = "svelte-check"

# format commands
const nphFormatCmd = "nph ."
const prettierFormatCmd = "bun run prettier . --write"
const eslintFixCmd = "bun run eslint --fix --ignore-pattern 'src/lib/nomuna.mjs'"

# lint commands
const reuseLintCmd = "reuse lint"
const nphLintCmd = "nph --check ."
const prettierLintCmd = "bun run prettier . --check"
const eslintLintCmd = "bun run eslint --ignore-pattern 'src/lib/nomuna.mjs'"
const svelteCheckLintCmd = "bun run check"

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
  # prettier
  let prettierFmtRes = runCmd(prettier, cmdTypeFmt, prettierFormatCmd)
  # eslint
  let eslintFmtRes = runCmd(eslint, cmdTypeFmt, eslintFixCmd)

  return nphFmtRes and prettierFmtRes and eslintFmtRes

proc lint(): bool =
  const cmdTypeLint = "lint"
  # reuse
  let reuseLintRes = runCmd(reuse, cmdTypeLint, reuseLintCmd)
  # nph
  let nphLintRes = runCmd(nph, cmdTypeLint, nphLintCmd)
  # prettier
  let prettierLintRes = runCmd(prettier, cmdTypeLint, prettierLintCmd)
  # eslint
  let eslintLintRes = runCmd(eslint, cmdTypeLint, eslintLintCmd)
  # svelte-check
  let svelteCheckLintRes = runCmd(svelteCheck, cmdTypeLint, svelteCheckLintCmd)

  return
    reuseLintRes and nphLintRes and prettierLintRes and eslintLintRes and
    svelteCheckLintRes

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
