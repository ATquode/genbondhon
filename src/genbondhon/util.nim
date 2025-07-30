# SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
#
# SPDX-License-Identifier: MIT

import std/[sequtils, sugar, options]
import compiler/ast

func subType*(node: PNode): TNodeKind =
  ## get actual type from TypeDef node
  ## Note: node needs to be TypeDef type node
  node[2].kind

func itemName*(node: PNode): string =
  ## get identifier name from node
  var itemNode = node[0]
  if itemNode.kind == nkPragmaExpr:
    itemNode = itemNode[0]
  if itemNode.kind == nkPostfix:
    itemNode = itemNode[1]
  else:
    itemNode = itemNode[0]
  return itemNode.ident.s

func enumNameValue*(node: PNode): (string, Option[int]) =
  ## get enum item name & value pair
  ## Note: node needs to be a non empty children of enum type (`nkEnumTy`)
  case node.kind
  of nkEnumFieldDef:
    result = (node[0].ident.s, some(node[1].intVal.int))
  of nkIdent:
    result = (node.ident.s, none(int))
  else:
    result = ("error: unexpeceted node", none(int))

func procName*(node: PNode): string {.deprecated: "use `itemName` instead".} =
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

func returnTypeContainsType(retTypeNode: PNode, reqType: string): bool =
  if retTypeNode.kind != nkEmpty and retTypeNode.ident.s == reqType: true else: false

func paramListContainsType(paramList: seq[PNode], reqType: string): bool =
  paramList.anyIt(it.paramType == reqType)

func containsType*(apis: seq[PNode], reqType: string): bool =
  for i in 0 ..< apis.len:
    let api = apis[i]
    if api.procParamNode.isNone:
      continue
    let formalParamNode = api.procParamNode.get()
    let retTypeNode = formalParamNode[0]
    if retTypeNode.returnTypeContainsType(reqType):
      return true
    if formalParamNode.safeLen == 1:
      continue
    let paramList = collect:
      for i in 1 ..< formalParamNode.safeLen:
        formalParamNode[i]
    if paramList.paramListContainsType(reqType):
      return true
  return false
