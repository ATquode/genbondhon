# SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
#
# SPDX-License-Identifier: MIT

import std/paths
import compiler/ast
import langs/[base, c, cpp, csharp, kotlin, swift, typescript]

proc getLangGens(bindingDir: Path, jvmPkgName: string): seq[BaseLangGen] =
  result.add newCLangGen(bindingDir)
  result.add newCppLangGen(bindingDir)
  result.add newCSharpLangGen(bindingDir)
  result.add newSwiftLangGen(bindingDir)
  result.add newKotlinLangGen(bindingDir, jvmPkgName)
  result.add newTypeScriptLangGen(bindingDir)

proc generateLanguageBindings*(
    bindingAST: seq[PNode], bindingDir: Path, jvmPkgName: string
) =
  let langGens = getLangGens(bindingDir, jvmPkgName)
  for langGen in langGens:
    langGen.generateBinding(bindingAST)
