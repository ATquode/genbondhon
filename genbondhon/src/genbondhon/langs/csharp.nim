import std/[options, paths, strformat, strutils, tables, terminal]
import compiler/ast
import base
import ../[convertutil, currentconfig, util]

type CSharpLangGen = ref object of BaseLangGen
  wrapperFileName: Path
  dllName: string

proc newCSharpLangGen*(bindingDir: Path): CSharpLangGen =
  result = CSharpLangGen(
    langDir: bindingDir / "C#".Path,
    wrapperFileName: moduleName.Path.addFileExt("cs"),
    dllName: moduleName & ".dll",
  )
  initBaseLangGen(result)

func replaceType(nimCType: string): string =
  nimCompatToCSharpTypeTbl.getOrDefault(nimCType, nimCType)

func translateProc(node: PNode, dllName: string): string =
  let funcName = procName(node)
  let paramNode = procParamNode(node)
  var retType = "void"
  var trParamList: seq[string]
  if paramNode.isSome:
    let formalParamNode = paramNode.get()
    for i in 1 ..< formalParamNode.safeLen:
      let paramName = formalParamNode[i][0].ident.s
      let paramType = formalParamNode[i][1].ident.s
      var trParam = &"{paramType.replaceType} {paramName}"
      if paramType.replaceType == "string":
        trParam = &"[MarshalAs(UnmanagedType.LPUTF8Str)] {trParam}"
      if paramType.replaceType == "bool":
        trParam = &"[MarshalAs(UnmanagedType.U1)] {trParam}"
      trParamList.add(trParam)
    if formalParamNode[0].kind != nkEmpty:
      retType = formalParamNode[0].ident.s
  result =
    &"""
        [DllImport("{dllName}", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Unicode, EntryPoint = "{funcName}")]
        public static extern {retType.replaceType} {funcName.capitalizeAscii}({trParamList.join(", ")});"""
  if retType.replaceType == "string":
    result =
      &"""
        [return: MarshalAs(UnmanagedType.LPUTF8Str)]
{result}"""
  elif retType.replaceType == "bool":
    result =
      &"""
        [return: MarshalAs(UnmanagedType.U1)]
{result}"""

func translateApi(api: PNode, dllName: string): string =
  case api.kind
  of nkProcDef, nkFuncDef, nkMethodDef:
    result = translateProc(api, dllName)
  else:
    result = "Cannot translate Api to C#"

func generateDllWrapperContent(
    bindingAST: seq[PNode], modName: string, dllName: string
): string =
  var cSharpApis: seq[string]
  for api in bindingAST:
    let trApi = translateApi(api, dllName)
    cSharpApis.add(trApi)
  result =
    &"""
using System.Runtime.InteropServices;

namespace {modName.capitalizeAscii}Lib
{{
    public class {modName.capitalizeAscii}
    {{
{cSharpApis.join("\n\n")}
    }}
}}
"""

proc generateCSharpDllWrapper(self: CSharpLangGen, bindingAST: seq[PNode]) =
  let content = generateDllWrapperContent(bindingAST, moduleName, self.dllName)
  if showVerboseOutput:
    styledEcho fgGreen, "CSharp Dll Wrapper Content:"
    echo content
  let wrapperFilePath = self.langDir / self.wrapperFileName
  self.ensureDir()
  wrapperFilePath.string.writeFile(content)

method getReadMeContent(self: CSharpLangGen): string =
  let common = procCall self.BaseLangGen.getReadMeContent()
  let realTestDir = testDirPath / "C#".Path
  result =
    &"""
{common}

### Note
This binding is tested only on Windows.

#### Static Library
Not supported

#### Dynamic Library

    nim c --cc:vcc -d:release --noMain:on --app:lib --outdir:{self.langDir.string} {self.bindingModuleFile.string}

### Usage
Copy the wrapper file and lib binary to your project.

    cp {string self.langDir / self.wrapperFileName} {realTestDir.string}
    cp {string self.langDir / self.dllName.Path} {realTestDir.string}
"""

method generateBinding*(self: CSharpLangGen, bindingAST: seq[PNode]) =
  self.generateCSharpDllWrapper(bindingAST)
  self.generateReadMe()
