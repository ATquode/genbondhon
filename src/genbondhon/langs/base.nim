# SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
#
# SPDX-License-Identifier: MIT

import std/[dirs, paths, strformat, tables]
import compiler/ast
import ../[convertutil, currentconfig, util]

type BaseLangGen* = ref object of RootObj
  langDir*: Path
  bindingModuleFile*: Path
  namedTypes: Table[string, NamedTypeCategory]
  flagEnums*: seq[string]
  ignoreApiList*: seq[string]

proc initBaseLangGen*(self: BaseLangGen) =
  self.bindingModuleFile = bindingDirPath / moduleName.Path.addFileExt("nim")

method generateBinding*(self: BaseLangGen, bindingAST: seq[PNode]) {.base.} =
  discard

proc storeNamedType*(
    self: BaseLangGen, typeName: string, typeCategory: NamedTypeCategory
) =
  if typeName in self.namedTypes:
    return
  self.namedTypes[typeName] = typeCategory

func typeCategory*(self: BaseLangGen, typeName: string): NamedTypeCategory =
  self.namedTypes.getOrDefault(typeName, NamedTypeCategory.noneType)

method translateEnum(self: BaseLangGen, node: PNode): (string, string) {.base.} =
  discard

proc markEnumFlag(self: BaseLangGen, enumType: string) =
  self.flagEnums.add(enumType)

proc translateContainer*(self: BaseLangGen, node: PNode): (string, string) =
  let containerType = node[2][0].ident.s
  let memberType = node[2][1].ident.s
  case containerType
  of "set":
    if memberType in self.namedTypes:
      self.markEnumFlag(memberType)
      result = (node.itemName, "")
    else:
      result = (node.itemName, "Api not supported: set")
  else:
    result = (node.itemName, "Cannot translate Api")

proc translateType*(self: BaseLangGen, node: PNode): (string, string) =
  case node.subType
  of nkEnumTy:
    result = self.translateEnum(node)
  of nkBracketExpr:
    result = self.translateContainer(node)
  else:
    result = (node.itemName, "Cannot translate Api")

method convertEnumToEnumFlag(self: BaseLangGen, enumBody: string): string {.base.} =
  discard

func handleEnumFlags*(
    self: BaseLangGen, apis: OrderedTable[string, string]
): OrderedTable[string, string] =
  if self.flagEnums.len == 0:
    return apis

  result = apis
  for flagEnum in self.flagEnums:
    if flagEnum notin apis:
      # echo &"Error!!! {flagEnum} not found in Api keys"
      continue
    let flagEnumBody = self.convertEnumToEnumFlag(result[flagEnum])
    result[flagEnum] = flagEnumBody

method getReadMeContent*(self: BaseLangGen): string {.base.} =
  result =
    &"""
### Build
Compile `{self.bindingModuleFile.string}` instead of `{origFile.string}`."""

proc generateReadMe*(self: BaseLangGen) =
  let content = self.getReadMeContent()
  let readMeFile = self.langDir / "ReadMe.md".Path
  readMeFile.string.writeFile(content)

proc ensureDir*(self: BaseLangGen, extraPath: Path = "".Path) =
  if not self.langDir.dirExists:
    self.langDir.createDir()
  if extraPath.string != "" and not extraPath.dirExists:
    extraPath.createDir()
