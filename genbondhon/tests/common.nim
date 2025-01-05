# SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
#
# SPDX-License-Identifier: MIT

import std/[os, osproc, strutils]

proc executeTask*(
    taskname: string, cmdstr: string = taskname, outputToStd = false, workingDir = "."
) =
  let cmd =
    if defined(windows):
      "powershell.exe " & cmdstr
    else:
      cmdstr
  let curPath = getCurrentDir()
  if outputToStd:
    setCurrentDir(workingDir)
  let code =
    if outputToStd:
      execCmd(cmd)
    else:
      execCmdEx(cmd, workingDir = workingDir).exitCode
  setCurrentDir(curPath)
  assert code == 0, "$# failed, code: $#".format(taskname, code)

proc findNimStdLib*(): string =
  ## Tries to find a path to a valid "system.nim" file.
  ## Returns "" on failure.
  ## modifying `findNimStdLib` from compiler/nimeval.nim
  try:
    let nimexe = os.findExe("nim")
      # this can't work with choosenim shims, refs https://github.com/dom96/choosenim/issues/189
      # it'd need `nim dump --dump.format:json . | jq -r .libpath`
      # which we should simplify as `nim dump --key:libpath`
    if nimexe.len == 0:
      return ""
    result = nimexe.splitPath()[0] /../ "lib"
    if not fileExists(result / "system.nim"):
      when defined(unix):
        result = nimexe.expandSymlink.splitPath()[0] /../ "lib"
        if not fileExists(result / "system.nim"):
          return ""
      else:
        result = result.splitPath()[0] / "apps/nim/current/lib" # for scoop
        if not fileExists(result / "system.nim"):
          return ""
  except OSError, ValueError:
    return ""

proc commonTasks*() =
  # build
  executeTask("nim build")
  # run
  let binaryName = if defined(windows): "genbondhon.exe" else: "genbondhon"
  var runCmd = "./dist/$# ./tests/nomuna.nim  --jvmPkgName com.example.myapplication1".format(
    binaryName
  )
  executeTask("genbondhon run", runCmd)

when isMainModule:
  commonTasks()
