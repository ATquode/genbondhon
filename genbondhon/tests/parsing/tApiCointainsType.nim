import std/[dirs, paths, unittest]
import
  ../../src/genbondhon/
    [currentconfig, parseutil, util, wrapperTranslator, wrapperGenerator]

let filePath = "tests/nomuna.nim".Path # Testament starts from parent of `tests` dir
origFile = filePath
moduleName = filePath.lastPathPart.splitFile.name.string
bindingDirPath = "bindingTest".Path
let wrappedFileName = "wrappedApi.nim"
let publicApis = filePath.parsePublicAPIs()
check publicApis.containsType("string")

let wrappedApis = publicApis.translateToCompatibleWrapperApi()
let wrappedFile = wrappedApis.generateWrapperFile(wrappedFileName)
let bindingApis = wrappedFile.parsePublicAPIs()
check bindingApis.containsType("bool")
check bindingApis.containsType("cstring")

dirs.removeDir(bindingDirPath)
