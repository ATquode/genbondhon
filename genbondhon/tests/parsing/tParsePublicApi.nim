# SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
#
# SPDX-License-Identifier: MIT

import std/[paths, strutils]
import ../../src/genbondhon/parseutil
import ../../src/genbondhon/util

let filePath = "tests/nomuna.nim".Path # Testament starts from parent of `tests` dir
let publicApis = filePath.parsePublicAPIs()
assert publicApis.len == 13,
  "The number of public Apis ($#) don't match".format(publicApis.len)

const expectedPublicProcs = ["noop", "extraNoOp"]
for i in 0 ..< expectedPublicProcs.len:
  assert publicApis[i].procName == expectedPublicProcs[i],
    "$# doesn't match $#".format(publicApis[i].procName, expectedPublicProcs[i])
