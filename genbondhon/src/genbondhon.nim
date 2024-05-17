# SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
#
# SPDX-License-Identifier: MIT

const helpTxt =
  """
Generate bindings for Nim libraries to platform native technologies.

Usage:
  genbondhon [--verbose] <file>
  genbondhon --version
  genbondhon -h | --help

Options:
  --verbose     Show verbose output.
  -h --help     Show help message.
  --version     Show version
"""

import std/[parsecfg, paths, streams]
import docopt
import docopt/dispatch
import genbondhon/[currentconfig, parseutil]

const version = "../genbondhon.nimble".staticRead.newStringStream.loadConfig.getSectionValue(
  "", "version"
)

proc generateBindings(verbose: bool, file: string) =
  ## generates bindings for public APIs of the given nim file.
  showVerboseOutput = verbose
  discard parsePublicAPIs(file.Path)

when isMainModule:
  let args = docopt(helpTxt, version = version)
  discard args.dispatchProc(generateBindings, "<file>")
