# SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
#
# SPDX-License-Identifier: MIT

const helpTxt =
  """
Generate bindings for Nim libraries to platform native technologies.

Usage:
  genbondhon <file>
  genbondhon --version
  genbondhon -h | --help

Options:
  -h --help     Show help message.
  --version     Show version
"""

import std/[parsecfg, streams]
import docopt
import docopt/dispatch

const version = "../genbondhon.nimble".staticRead.newStringStream.loadConfig.getSectionValue(
  "", "version"
)

proc generateBindings(file: string) =
  echo file

when isMainModule:
  let args = docopt(helpTxt, version = version)
  discard args.dispatchProc(generateBindings, "<file>")
