# SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
#
# SPDX-License-Identifier: MIT

import std/options
import compiler/ast

func procName*(node: PNode): string =
  ## get proc/func/method name from node
  ## Note: node needs to be proc/func/method type node,
  ## proc needs to be **public**
  node[0][1].ident.s

func procParamNode*(node: PNode): Option[PNode] =
  ## get `nkFormalParams` node from `node`
  for i in countdown(node.safeLen - 1, 0):
    if node[i].kind == nkFormalParams:
      return some(node[i])
  return none(PNode)

func paramName*(node: PNode): string =
  ## get paramName from `procParamNode`
  ## Note: node needs to be formal param node type
  node[0].ident.s

func paramType*(node: PNode): string =
  ## get paramType from `procParamNode`
  ## Note: node needs to be formal param node type
  node[1].ident.s
