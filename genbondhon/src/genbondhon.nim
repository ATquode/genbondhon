# SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
#
# SPDX-License-Identifier: MIT

const helpTxt =
  """
Generate bindings for Nim libraries to platform native technologies.

Usage:
  genbondhon [-b <bindingDirName>] [-w <wrapperFileName>] [--verbose] <file>
  genbondhon [--bindingDir <bindingDirName>] [--wrapperName <wrapperFileName>] [--verbose] <file>
  genbondhon --version
  genbondhon -h | --help

Options:
  -b <bindingDirName>, --bindingDir <bindingDirName>          Binding Directory Path [default: bindings].
  -w <wrapperFileName>, --wrapperName <wrapperFileName>       Wrapper File Name [default: binding_api].
  --verbose                                                   Show verbose output.
  -h --help                                                   Show help message.
  --version                                                   Show version
"""

import std/[parsecfg, paths, streams]
import docopt
import docopt/dispatch
import genbondhon/[currentconfig, parseutil, wrapperGenerator, wrapperTranslator]

const version = "../genbondhon.nimble".staticRead.newStringStream.loadConfig.getSectionValue(
  "", "version"
)

proc generateBindings(
    bindingDir: string, wrapperName: string, verbose: bool, file: string
) =
  ## generates bindings for public APIs of the given nim file.
  showVerboseOutput = verbose
  moduleName = file.Path.lastPathPart.splitFile.name.string
  let publicAST = parsePublicAPIs(file.Path)
  let wrappedApis = translateToCompatibleWrapperApi(publicAST)
  discard wrappedApis.generateWrapperFile(bindingDir.Path, wrapperName, file.Path)
  generateBindableModule(bindingDir.Path, wrapperName)

when isMainModule:
  let args = docopt(helpTxt, version = version)
  discard args.dispatchProc(generateBindings, "<file>")
