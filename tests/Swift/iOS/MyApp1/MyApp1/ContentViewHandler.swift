// SPDX-FileCopyrightText: 2025 Rifat Hasan <atunutemp1@gmail.com>
//
// SPDX-License-Identifier: MIT

//
//  ContentViewHandler.swift
//  MyApp1
//
//  Created by Atunu on 1/2/25.
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
    @Published var direction: Direction

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

    var oppositeDirection: Direction {
        return getOpposite(direction: direction)
    }

    init() {
        sayHelloInput = ""
        direction = .south
        printCond(a: addIntRes == 0)
        printCond(a: addIntRes != 0)
        takeChar(a: "a")
        printStr(a: "nim")
        printStr(a: "hello ñíℳ")
        print2Str(str1: "Hello", str2: "World!")
        var direction = Direction.south
        printDirectionRawValue(direction: direction)
        direction = getDirection(hint: "south")
        print("Direction: \(direction), value: \(direction.rawValue)")
        let gameState = GameState.game_over
        print("Game State: \(gameState), value: \(gameState.rawValue)")
        let newGameState = togglePause(curState: gameState)
        print("Game State: \(newGameState), value: \(newGameState.rawValue)")
        var statusCode = authenticate(username: "user1")
        print("Status code: \(statusCode), value: \(statusCode.rawValue)")
        statusCode = setGameState(username: "user", state: GameState.game_over)
        print("set Game State result: \(statusCode), value: \(statusCode.rawValue)")
    }
}
