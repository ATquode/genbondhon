# SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
#
# SPDX-License-Identifier: MIT

import std/[paths, terminal]
import compiler/[ast, astalgo, idents, parser, wordrecg]
import currentconfig

proc parseFile(file: Path): PNode =
  ## parses nim file to AST.
  let content = readFile(file.string)
  let cache = newIdentCache()
  let node = parseString(content, cache, configRef, file.lastPathPart.string)
  # if showVerboseOutput:
  #   styledEcho styleBright, fgYellow, "Full AST:"
  #   echo treeToYaml(configRef, node)
  return node

func isExported(node: PNode): bool =
  ## checks if the given node is exported.
  ## modifying `isExported` from compiler/renderer.nim
  ## and `isVisible` from docgen.nim
  if not node.safeLen > 0:
    return false
  let n = node[0]
  case n.kind
  of nkPostfix:
    n.len == 2 and n[0].kind == nkIdent and n[0].ident.s == $wStar and
      n[1].kind == nkIdent
  of nkPragmaExpr:
    n.isExported()
  else:
    false

func trimToSignature(node: PNode): PNode =
  ## Trims proc/func/method nodes to only the proc signature AST,
  ## removing the body parts of them.
  if node.kind notin [nkProcDef, nkFuncDef, nkMethodDef]:
    return node
  var endIndex = 0
  for i in 0 ..< node.safeLen:
    if node[i].kind == nkStmtList:
      endIndex = i - 1
      break
  while node[endIndex].kind == nkEmpty:
    dec endIndex
  node.sons = node.sons[0 .. endIndex]
  return node

func filterPublicApis*(node: PNode): seq[PNode] =
  ## filters public APIs from the given node,
  ## returns them as sequence of nodes.
  case node.kind
  of nkStmtList:
    for i in 0 ..< node.safeLen:
      let filteredNodes = filterPublicApis(node[i])
      result.add(filteredNodes)
  of nkTypeSection:
    for i in 0 ..< node.safeLen:
      let filteredNodes = filterPublicApis(node[i])
      result.add(filteredNodes)
  of nkProcDef, nkFuncDef, nkMethodDef:
    if node.isExported:
      let trNode = node.trimToSignature()
      result.add(trNode)
  of nkTypeDef:
    if node.isExported:
      result.add(node)
  else:
    discard

proc parsePublicAPIs*(file: Path): seq[PNode] =
  ## parses nim file to a sequence of
  ## ASTs, where the ASTs are of public access.
  let rootNode = parseFile(file)
  let apiNodes = filterPublicApis(rootNode)
  # if showVerboseOutput:
  #   styledEcho styleBright, fgYellow, "Public exported AST:"
  #   for node in apiNodes:
  #     echo treeToYaml(configRef, node)
  return apiNodes
