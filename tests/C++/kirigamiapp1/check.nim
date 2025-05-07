#!/usr/bin/env nimcr

# SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
#
# SPDX-License-Identifier: MIT

import std/[osproc, sequtils, strutils, terminal]

# command names
const reuse = "reuse"
const nph = "nph"
const clangformat = "clang-format"
const clangtidy = "clang-tidy"
const clazy = "clazy"
const qmlformat = "qmlformat"
const qmllint = "qmllint"
const cmakeformat = "cmake-format"
const cmakelint = "cmake-lint"

# format commands
const nphFormatCmd = "nph ."
const clangformatFormatCmd = "clang-format -i "
const clangtidyFixCmd = "clang-tidy --fix -p "
const qmlformatFormatCmd =
  "/usr/lib/qt6/bin/qmlformat -i --normalize --objects-spacing --functions-spacing "
const qmllintFixCmd = "/usr/lib/qt6/bin/qmllint --compiler warning --fix "
const cmakeformatFormatCmd = "cmake-format -i "

# lint commands
const reuseLintCmd = "reuse lint"
const nphLintCmd = "nph --check ."
const clangformatLintCmd = "clang-format --dry-run -Werror "
const clangtidyLintCmd = "clang-tidy -p "
const clazyLintCmd = "clazy-standalone -p "
const qmllintLintCmd = "/usr/lib/qt6/bin/qmllint --compiler warning "
const cmakeformatLintCmd = "cmake-format --check "
const cmakelintLintCmd = "cmake-lint "

var trackedFiles: seq[string]
var cppFiles: string
var qmlFiles: string
var cmakeFiles: string
var compileCommandsJsonPath: string

proc storeTrackedFileList() =
  let (cmdOutput, _) = execCmdEx("git ls-files")
  trackedFiles = cmdOutput.splitLines.filterIt(it.len != 0)
  cppFiles = trackedFiles.filterIt(it.endsWith(".h") or it.endsWith(".cpp")).join(" ")
  qmlFiles = trackedFiles.filterIt(it.endsWith(".qml")).join(" ")
  cmakeFiles = trackedFiles
    .filterIt(it.endsWith("CMakeLists.txt") or it.endsWith(".cmake"))
    .join(" ")

proc build() =
  let buildDir = "build"
  let cmakeConfigCmd = "cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -S . -B " & buildDir
  echo "configuring..."
  let (configOutput, configResult) = execCmdEx(cmakeConfigCmd)
  if configResult != 0:
    echo configOutput
  echo "Configure Result: ", configResult
  compileCommandsJsonPath = buildDir
  let sedReplaceCmd =
    "sed -i 's/ -mno-direct-extern-access//g' " & compileCommandsJsonPath &
    "/compile_commands.json"
  let (sedOutput, sedResult) = execCmdEx(sedReplaceCmd)
  if sedResult != 0:
    echo sedOutput
  echo "Sed Replace Result for clang-tidy: ", sedResult
  let cmakeBuildCmd = "cmake --build " & buildDir & " --target all"
  echo "building..."
  let (buildOutput, buildResult) = execCmdEx(cmakeBuildCmd)
  if buildResult != 0:
    echo buildOutput
  echo "Build Result: ", buildResult

proc sedReplaceForClazy() =
  let sedReplaceCmd =
    "sed -i 's/ -Wlogical-op//g' " & compileCommandsJsonPath & "/compile_commands.json"
  let (sedOutput, sedResult) = execCmdEx(sedReplaceCmd)
  if sedResult != 0:
    echo sedOutput
  echo "Sed Replace Result for Clazy: ", sedResult

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
  # clang-format
  let clangformatFmtRes =
    runCmd(clangformat, cmdTypeFmt, clangformatFormatCmd & cppFiles)
  # clang-tidy
  let clangtidyFmtRes = runCmd(
    clangtidy, cmdTypeFmt, clangtidyFixCmd & compileCommandsJsonPath & " " & cppFiles
  )
  # qmlformat
  let qmlformatFmtRes = runCmd(qmlformat, cmdTypeFmt, qmlformatFormatCmd & qmlFiles)
  # qmllint
  let qmllintFmtRes = runCmd(qmllint, cmdTypeFmt, qmllintFixCmd & qmlFiles)
  # cmake-format
  let cmakeformatFmtRes =
    runCmd(cmakeformat, cmdTypeFmt, cmakeformatFormatCmd & cmakeFiles)

  return
    nphFmtRes and clangformatFmtRes and clangtidyFmtRes and qmlformatFmtRes and
    qmllintFmtRes and cmakeformatFmtRes #and swiftlintFmtRes

proc lint(): bool =
  const cmdTypeLint = "lint"
  # reuse
  let reuseLintRes = runCmd(reuse, cmdTypeLint, reuseLintCmd)
  # nph
  let nphLintRes = runCmd(nph, cmdTypeLint, nphLintCmd)
  # clang-format
  let clangformatLintRes = runCmd(clangformat, cmdTypeLint, clangformatLintCmd)
  # clang-tidy
  let clangtidyLintRes = runCmd(
    clangtidy, cmdTypeLint, clangtidyLintCmd & compileCommandsJsonPath & " " & cppFiles
  )
  # clazy
  sedReplaceForClazy()
  let clazyLintRes =
    runCmd(clazy, cmdTypeLint, clazyLintCmd & compileCommandsJsonPath & " " & cppFiles)
  # qmllint
  let qmllintLintRes = runCmd(qmllint, cmdTypeLint, qmllintLintCmd & qmlFiles)
  # cmake-format
  let cmakeformatLintRes =
    runCmd(cmakeformat, cmdTypeLint, cmakeformatLintCmd & cmakeFiles)
  # cmake-lint
  let cmakelintLintRes = runCmd(cmakelint, cmdTypeLint, cmakelintLintCmd & cmakeFiles)

  return
    reuseLintRes and nphLintRes and clangformatLintRes and clangtidyLintRes and
    clazyLintRes and qmllintLintRes and cmakeformatLintRes and cmakelintLintRes

when isMainModule:
  storeTrackedFileList()
  build()
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
