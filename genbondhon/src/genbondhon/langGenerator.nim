# SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
#
# SPDX-License-Identifier: MIT

import std/paths
import compiler/ast
import langs/[base, c, cpp, csharp, swift]

proc getLangGens(bindingDir: Path): seq[BaseLangGen] =
  result.add newCLangGen(bindingDir)
  result.add newCppLangGen(bindingDir)
  result.add newCSharpLangGen(bindingDir)
  result.add newSwiftLangGen(bindingDir)

proc generateLanguageBindings*(bindingAST: seq[PNode], bindingDir: Path) =
  let langGens = getLangGens(bindingDir)
  for langGen in langGens:
    langGen.generateBinding(bindingAST)
