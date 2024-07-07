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

proc commonTasks*() =
  # build
  executeTask("nim build")
  # run
  let binaryName = if defined(windows): "genbondhon.exe" else: "genbondhon"
  let runCmd = "./dist/$# ./tests/nomuna.nim".format(binaryName)
  executeTask("genbondhon run", runCmd)
