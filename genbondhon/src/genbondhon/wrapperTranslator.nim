# SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
#
# SPDX-License-Identifier: MIT

import std/[strformat, strutils, terminal]
import compiler/ast
import currentconfig, util

proc translateProc(node: PNode): string =
  let procName = procName(node)
  result =
    &"""
proc {procName}*() {{.raises:[], exportc, cdecl, dynlib.}} =
  {moduleName}.{procName}()
"""

proc wrapApi(api: PNode): string =
  case api.kind
  of nkProcDef, nkFuncDef, nkMethodDef:
    result = translateProc(api)
  else:
    result = "Cannot wrap api"

proc generateWrapperContent(publicAST: seq[PNode]): string =
  var trApis = newSeq[string]()
  for api in publicAST:
    let wrappedApi = wrapApi(api)
    trApis.add(wrappedApi)
  result =
    &"""
{trApis.join("\n\n")}
"""

proc translateToCompatibleWrapperApi*(publicAST: seq[PNode]): string =
  let apiContent = generateWrapperContent(publicAST)
  if showVerboseOutput:
    styledEcho fgYellow, "Wrapped Apis:"
    echo apiContent
  return apiContent
