// SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
//
// SPDX-License-Identifier: MIT

//
//  ContentViewHandler.swift
//  App1
//
//  Created by Atunu on 7/24/24.
//

import Foundation

class ContentViewHandler: ObservableObject {
    @Published var addInt1: Int?
    @Published var addInt2: Int?
    @Published var addDouble1: Double?
    @Published var addDouble2: Double?
    @Published var addFloat1: Float?
    @Published var addFloat2: Float?
    @Published var sayHelloInput: String

    var addIntRes: Int {
        let num1 = addInt1 ?? 0
        let num2 = addInt2 ?? 0
        return addIntNum(a: num1, b: num2)
    }

    var addDoubleRes: Double {
        let num1 = addDouble1 ?? 0
        let num2 = addDouble2 ?? 0
        return addDouble(a: num1, b: num2)
    }

    var addFloatRes: Float {
        let num1 = addFloat1 ?? 0
        let num2 = addFloat2 ?? 0
        return addFloat(a: num1, b: num2)
    }

    var sayHelloOutput: String {
        return sayHello(name: sayHelloInput)
    }

    init() {
        sayHelloInput = ""
        printCond(a: addIntRes == 0)
        printCond(a: addIntRes != 0)
        takeChar(a: "a")
        printStr(a: "nim")
        printStr(a: "hello ñíℳ")
        print2Str(str1: "Hello", str2: "World!")
    }
}
