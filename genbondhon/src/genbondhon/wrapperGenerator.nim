# SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
#
# SPDX-License-Identifier: MIT

import std/[dirs, paths, strformat, terminal]
import currentconfig

proc relativeModulePath(): string =
  let relModFilePath = origFile.relativePath(bindingDirPath, '/')
  let relModPath = relModFilePath.changeFileExt("")
  result = relModPath.string

proc generateWrapperFileContent(wrappedApis: string): string =
  let modulePath = relativeModulePath()
  let vccCondImport =
    if shouldUseVCCStr:
      &"""

when defined(vcc):
  proc CoTaskMemAlloc(cb: int): cstring {{.cdecl, dynlib: "ole32.dll", importc.}}
"""
    else:
      ""
  result =
    &"""
import {modulePath}
{vccCondImport}
{wrappedApis}"""

proc generateWrapperFile*(wrappedApis: string, wrapperName: string): Path =
  ## Generates wrapper file in `bindingDir` with `wrapperName`.
  ## Returns wrapper file path.
  let fileName = wrapperName.Path.addFileExt("nim")
  if not bindingDirPath.dirExists:
    try:
      bindingDirPath.createDir()
    except:
      let exceptionMsg = getCurrentExceptionMsg()
      styledEcho fgRed,
        "Error: Failed to create binding directory. Reason: ", exceptionMsg
      return
  let filePath = bindingDirPath / fileName
  let nimMainStr = "proc NimMain*() {.raises:[], exportc, cdecl, dynlib, importc.}"
  let wrapperApis =
    &"""
{nimMainStr}

{wrappedApis}"""
  let fileContent = generateWrapperFileContent(wrapperApis)
  if showVerboseOutput:
    styledEcho fgYellow, "Wrapper File Content:"
    echo fileContent
  filePath.string.writeFile(fileContent)
  return filePath

proc generateBindableModule*(bindingDir: Path, wrapperName: string) =
  let moduleFileName = moduleName.Path.addFileExt("nim")
  let moduleFilePath = bindingDir / moduleFileName
    # assume the directory already exists, because wrapper file has been created.
  let content =
    &"""
include {wrapperName}
"""
  moduleFilePath.string.writeFile(content)
