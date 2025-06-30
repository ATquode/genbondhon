# SPDX-FileCopyrightText: 2025 Rifat Hasan <atunutemp1@gmail.com>
#
# SPDX-License-Identifier: MIT

#!fmt: off
discard """
  output: '''
No Operation
extra: No Op.
2
true
2.3
a
what
প্রোগ্রামিং
8
success
failure
8.08
8.8
a
nim
hello ñíℳ
Héllø ñíℳ
Hello World!
direction raw value: 2'''
"""
#!fmt: on

import ../common

proc testRunningScript(moduleName: string) =
  # compile nim lib
  let libCompileCmd =
    "nim js -d:release --noMain:on --app:lib --out:bindings/ts/nomuna.mjs bindings/nomuna.nim"
  executeTask("nim library compilation", libCompileCmd)
  # copy TS declaration file
  let copyDeclFileCmd = "cp bindings/ts/nomuna.d.ts tests/ts"
  executeTask("Copy declaration file", copyDeclFileCmd)
  # copy JS module
  let copyModuleCmd = "cp bindings/ts/nomuna.mjs tests/ts"
  executeTask("Copy module", copyModuleCmd)
  # run TS script
  let runScriptCmd = "bun testCode.ts"
  executeTask(
    "Running testCode.ts", runScriptCmd, outputToStd = true, workingDir = "tests/ts"
  )

when isMainModule:
  let moduleName = "nomuna"

  testRunningScript(moduleName)
