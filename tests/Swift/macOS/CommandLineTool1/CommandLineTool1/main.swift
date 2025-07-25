// SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
//
// SPDX-License-Identifier: MIT

//
//  main.swift
//  CommandLineTool1
//
//  Created by Atunu on 7/17/24.
//

import Foundation

NimMain()
noop()
extraNoOp()
let a = constRet()
print(a)
let b = constRetBool()
print(b)
let c = constRetFloat()
print(c)
let d = constRetChar()
print(d)
let e = constRetStr()
print(e)
let f = constRetUnicodeStr()
print(f)
let g = addIntNum(a: 5, b: 3)
print(g)
printCond(a: g == 8)
printCond(a: g != 8)
let h = addDouble(a: 5.03, b: 3.05)
print(h)
let i = addFloat(a: 5.3, b: 3.5)
print(i)
takeChar(a: "a")
printStr(a: "nim")
printStr(a: "hello ñíℳ")
let j = sayHello(name: "ñíℳ")
print(j)
print2Str(str1: "Hello", str2: "World!")
let direction = Direction.south
printDirectionRawValue(direction: direction)
