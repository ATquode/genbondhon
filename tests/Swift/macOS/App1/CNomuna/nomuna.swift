// SPDX-FileCopyrightText: 2025 Rifat Hasan <atunutemp1@gmail.com>
//
// SPDX-License-Identifier: MIT

import CNomuna

enum Direction: CUnsignedInt {
    case north
    case east
    case south
    case west
}

enum GameState: CUnsignedInt {
    case playing = 100
    case pause
    case game_over
}

enum HttpStatusCode: CUnsignedInt {
    case ok = 200
    case created
    case no_content = 204
    case moved_permanently = 301
    case found
    case not_modified = 304
    case bad_request = 400
    case unauthorized
    case forbidden = 403
    case not_found
    case internal_server_error = 500
    case bad_gateway = 502
    case service_unavailable
}

func NimMain() {
    CNomuna.NimMain()
}

func noop() {
    CNomuna.noop()
}

func extraNoOp() {
    CNomuna.extraNoOp()
}

func constRet() -> Int {
    return Int(CNomuna.constRet())
}

func constRetBool() -> Bool {
    return Bool(CNomuna.constRetBool())
}

func constRetFloat() -> Double {
    return Double(CNomuna.constRetFloat())
}

func constRetChar() -> Character {
    return Character(UnicodeScalar(UInt8(bitPattern: CNomuna.constRetChar())))
}

func constRetStr() -> String {
    let temp = CNomuna.constRetStr()
    guard let data = temp else {
        print("Error!! Failed to get string from constRetStr")
        return "Failed to get string from constRetStr"
    }
    return String(cString: data)
}

func constRetUnicodeStr() -> String {
    let temp = CNomuna.constRetUnicodeStr()
    guard let data = temp else {
        print("Error!! Failed to get string from constRetUnicodeStr")
        return "Failed to get string from constRetUnicodeStr"
    }
    return String(cString: data)
}

func addIntNum(a: Int, b: Int) -> Int {
    return Int(CNomuna.addIntNum(CInt(a), CInt(b)))
}

func printCond(a: Bool) {
    CNomuna.printCond(a)
}

func addDouble(a: Double, b: Double) -> Double {
    return Double(CNomuna.addDouble(CDouble(a), CDouble(b)))
}

func addFloat(a: Float, b: Float) -> Float {
    return Float(CNomuna.addFloat(CFloat(a), CFloat(b)))
}

func takeChar(a: Character) {
    CNomuna.takeChar(String(a).utf8CString[0])
}

func printStr(a: String) {
    CNomuna.printStr(a)
}

func sayHello(name: String) -> String {
    let temp = CNomuna.sayHello(name)
    guard let data = temp else {
        print("Error!! Failed to get string from sayHello")
        return "Failed to get string from sayHello"
    }
    return String(cString: data)
}

func print2Str(str1: String, str2: String) {
    CNomuna.print2Str(str1, str2)
}

func printDirectionRawValue(direction: Direction) {
    CNomuna.printDirectionRawValue(CNomuna.Direction(direction.rawValue))
}

func getDirection(hint: String) -> Direction {
    let cEnum = CNomuna.getDirection(hint)
    let sEnum = Direction(rawValue: cEnum.rawValue)
    guard let data = sEnum else {
        fatalError("Error!! Failed to get enum Direction from getDirection")
    }
    return data
}

func getOpposite(direction: Direction) -> Direction {
    let cEnum = CNomuna.getOpposite(CNomuna.Direction(direction.rawValue))
    let sEnum = Direction(rawValue: cEnum.rawValue)
    guard let data = sEnum else {
        fatalError("Error!! Failed to get enum Direction from getOpposite")
    }
    return data
}

func togglePause(curState: GameState) -> GameState {
    let cEnum = CNomuna.togglePause(CNomuna.GameState(curState.rawValue))
    let sEnum = GameState(rawValue: cEnum.rawValue)
    guard let data = sEnum else {
        fatalError("Error!! Failed to get enum GameState from togglePause")
    }
    return data
}

func authenticate(username: String) -> HttpStatusCode {
    let cEnum = CNomuna.authenticate(username)
    let sEnum = HttpStatusCode(rawValue: cEnum.rawValue)
    guard let data = sEnum else {
        fatalError("Error!! Failed to get enum HttpStatusCode from authenticate")
    }
    return data
}

func setGameState(username: String, state: GameState) -> HttpStatusCode {
    let cEnum = CNomuna.setGameState(username, CNomuna.GameState(state.rawValue))
    let sEnum = HttpStatusCode(rawValue: cEnum.rawValue)
    guard let data = sEnum else {
        fatalError("Error!! Failed to get enum HttpStatusCode from setGameState")
    }
    return data
}
