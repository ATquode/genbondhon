# SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
#
# SPDX-License-Identifier: MIT

const helpTxt =
  """
Generate bindings for Nim libraries to platform native technologies.

Usage:
  genbondhon -h | --help

Options:
  -h --help     Show help message.
  --version     Show version
"""

import std/[parsecfg, streams]
import docopt

const version = "../genbondhon.nimble".staticRead.newStringStream.loadConfig.getSectionValue(
  "", "version"
)

when isMainModule:
  discard docopt(helpTxt, version = version)
