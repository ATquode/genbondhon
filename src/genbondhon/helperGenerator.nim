# SPDX-FileCopyrightText: 2026 Rifat Hasan<atunutemp1@gmail.com>
#
# SPDX-License-Identifier: MIT

import std/[paths, sequtils, strformat, strutils]
import currentconfig

var anonymousTuples*, cppEnums*: seq[string]

proc generateHelperFile*() =
  let fileName = "helper_types.h".Path
  let filePath = bindingDirPath / fileName
  let cppEnumSection =
    if cppEnums.len != 0:
      &"""#ifdef __cplusplus

{cppEnums.join("\n\n")}

#endif /* __cplusplus */"""
    else:
      ""
  let cTupleSection = anonymousTuples.join("\n\n")
  let helperTypes = [cppEnumSection, cTupleSection].filterIt(it != "").join("\n\n")
  if helperTypes.len == 0:
    return
  let fileContent =
    &"""
#ifndef HELPER_TYPES_H
#define HELPER_TYPES_H

{helperTypes}

#endif /* HELPER_TYPES_H */
"""
  filePath.string.writeFile(fileContent)
