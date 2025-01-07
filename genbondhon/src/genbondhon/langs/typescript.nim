# SPDX-FileCopyrightText: 2025 Rifat Hasan <atunutemp1@gmail.com>
#
# SPDX-License-Identifier: MIT

import std/[options, paths, strformat, strutils, tables, terminal]
import base
import compiler/ast
import ../[convertutil, currentconfig, util]

type TypeScriptLangGen = ref object of BaseLangGen
  declarationFileName: Path

proc newTypeScriptLangGen*(bindingDir: Path): TypeScriptLangGen =
  ## `TypeScriptLangGen` constructor
  result = TypeScriptLangGen(
    langDir: bindingDir / "ts".Path,
    declarationFileName: moduleName.Path.addFileExt("d.ts"),
  )
  initBaseLangGen(result)

func replaceType(nimCType: string): string =
  ## Replaces Nim Compat Types to TypeScript Types
  nimCompatToTypeScriptTypeTbl.getOrDefault(nimCType, nimCType)

func translateProc(node: PNode): string =
  let funcName = procName(node)
  if funcName == "NimMain":
    return ""
  let paramNode = procParamNode(node)
  var retType = ""
  var trParamList: seq[string]
  if paramNode.isSome:
    let formalParamNode = paramNode.get()
    for i in 1 ..< formalParamNode.safeLen:
      let paramName = formalParamNode[i].paramName
      let paramType = formalParamNode[i].paramType
      let trParam = &"{paramName}: {paramType.replaceType}"
      trParamList.add(trParam)
    if formalParamNode[0].kind != nkEmpty:
      retType = formalParamNode[0].ident.s
  let retTypePart =
    if retType == "":
      ""
    else:
      &": {retType.replaceType}"
  result =
    &"""
export function {funcName}({trParamList.join(", ")}){retTypePart};"""

func translateApi(api: PNode): string =
  case api.kind
  of nkProcDef, nkFuncDef, nkMethodDef:
    result = translateProc(api)
  else:
    result = "Cannot translate Api to TypeScript"

func generateTypeScriptWrapperContent(
    self: TypeScriptLangGen, bindingAST: seq[PNode]
): string =
  var typescriptApis: seq[string]
  for api in bindingAST:
    let trApi = translateApi(api)
    if trApi != "":
      typescriptApis.add(trApi)
  result =
    &"""
{typescriptApis.join("\n\n")}
"""

proc generateTypeScriptDeclaration(self: TypeScriptLangGen, bindingAST: seq[PNode]) =
  let content = self.generateTypeScriptWrapperContent(bindingAST)
  if showVerboseOutput:
    styledEcho fgGreen, "TypeScript Declaration file content:"
    echo content
  let declarationFilePath = self.langDir / self.declarationFileName
  self.ensureDir()
  declarationFilePath.string.writeFile(content)

method getReadMeContent(self: TypeScriptLangGen): string =
  let common = procCall self.BaseLangGen.getReadMeContent()
  result =
    &"""
{common}
Use the `js` backend to generate the library.

    nim js -d:release --noMain:on --app:lib --out:{string self.langDir / moduleName.Path}.mjs {self.bindingModuleFile.string}

Modify `tsconfig.json`.
The module value should be set to a compatible ESModule (e.g. ESNext),
and allowJS should be set to true. Check if extends already did, if not, add your own.

    {{
      ...
      "compilerOptions": {{
        ...
        "module": "ESNext",
        ...
        "allowJs": true,
        ...
      }},
      ...
    }}

Now copy `{moduleName}.d.ts` and `{moduleName}.mjs` to your project.
Put them in your preferred location and import without extension.
e.g. If in the same directory, then use `import {{...}} from ./{moduleName}`.
"""

method generateBinding*(self: TypeScriptLangGen, bindingAST: seq[PNode]) =
  ## Generates binding & documentation for TypeScript
  self.generateTypeScriptDeclaration(bindingAST)
  self.generateReadMe()
