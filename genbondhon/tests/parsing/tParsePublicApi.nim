# SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
#
# SPDX-License-Identifier: MIT

import std/[paths, strutils]
import ../../src/genbondhon/parseutil
import ../../src/genbondhon/util

let filePath = "tests/nomuna.nim".Path # Testament starts from parent of `tests` dir
let publicApis = filePath.parsePublicAPIs()
assert publicApis.len == 2

const expectedPublicProcs = ["noop", "extraNoOp"]
for i, api in publicApis:
  assert api.procName == expectedPublicProcs[i],
    "$# doesn't match $#".format(api.procName, expectedPublicProcs[i])
