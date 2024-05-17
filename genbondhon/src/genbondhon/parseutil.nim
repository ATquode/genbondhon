# SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
#
# SPDX-License-Identifier: MIT

import std/paths
import compiler/[ast, astalgo, idents, options, parser]
import currentconfig

proc parseFile(file: Path): PNode =
  ## parses nim file to AST.
  let content = readFile(file.string)
  let cache = newIdentCache()
  let config = newConfigRef()
  let node = parseString(content, cache, config, file.lastPathPart.string)
  if showVerboseOutput:
    echo "Full AST:"
    echo treeToYaml(config, node)
  return node

proc parsePublicAPIs*(file: Path): seq[PNode] =
  ## parses nim file to a sequence of
  ## ASTs, where the ASTs are of public access.
  discard parseFile(file)
