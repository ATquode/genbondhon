# SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
#
# SPDX-License-Identifier: MIT

# Package
#!fmt: off
version       = "0.0.1"
author        = "Rifat Hasan"
description   = "An attempt to generate bindings for Nim libraries to platform native technologies."
license       = "MIT"
srcDir        = "src"
bin           = @["genbondhon"]
#!fmt: on

# Dependencies

requires "nim >= 2.0.0"

requires "docopt"
