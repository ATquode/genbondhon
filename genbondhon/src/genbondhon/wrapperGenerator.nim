# SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
#
# SPDX-License-Identifier: MIT

import std/[dirs, paths, strformat, terminal]
import currentconfig

proc relativeModulePath(bindingDir: Path, srcFile: Path): string =
  let relModFilePath = srcFile.relativePath(bindingDir, '/')
  let relModPath = relModFilePath.changeFileExt("")
  result = relModPath.string

proc generateWrapperFileContent(
    bindingDir: Path, srcFile: Path, wrappedApis: string
): string =
  let modulePath = bindingDir.relativeModulePath(srcFile)
  result =
    &"""
import {modulePath}

{wrappedApis}"""

proc generateWrapperFile*(
    wrappedApis: string, bindingDir: Path, wrapperName: string, srcFile: Path
): Path =
  ## Generates wrapper file in `bindingDir` with `wrapperName`.
  ## Returns wrapper file path.
  let fileName = wrapperName.Path.addFileExt("nim")
  if not bindingDir.dirExists:
    try:
      bindingDir.createDir()
    except:
      let exceptionMsg = getCurrentExceptionMsg()
      styledEcho fgRed,
        "Error: Failed to create binding directory. Reason: ", exceptionMsg
      return
  let filePath = bindingDir / fileName
  let fileContent = bindingDir.generateWrapperFileContent(srcFile, wrappedApis)
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
