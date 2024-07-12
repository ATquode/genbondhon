# SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
#
# SPDX-License-Identifier: MIT

import std/[paths, terminal]
import compiler/[ast, astalgo, idents, parser]
import langs/[base, c, csharp, swift]
import currentconfig, parseutil

proc getLangGens(bindingDir: Path): seq[BaseLangGen] =
  result.add newCLangGen(bindingDir)
  result.add newCSharpLangGen(bindingDir)
  result.add newSwiftLangGen(bindingDir)

proc generateNimMainNode(): PNode =
  let nimMain = "proc NimMain*()"
  let cache = newIdentCache()
  let node = parseString(nimMain, cache, configRef, "Manual addition")
  if showVerboseOutput:
    styledEcho fgYellow, "NimMain AST:"
    echo treeToYaml(configRef, node)
  let nodeSeq = filterPublicApis(node)
  if showVerboseOutput:
    styledEcho fgYellow, "Public exported NimMain AST:"
    for n in nodeSeq:
      echo treeToYaml(configRef, n)
  assert nodeSeq.len == 1
  result = nodeSeq[0]

proc generateLanguageBindings*(bindingAST: seq[PNode], bindingDir: Path) =
  let node = generateNimMainNode()
  var nBindAst = bindingAST
  nBindAst.insert(node, 0)
  let langGens = getLangGens(bindingDir)
  for langGen in langGens:
    langGen.generateBinding(nBindAst)
