// SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
//
// SPDX-License-Identifier: MIT

#include <iostream>
#include <iomanip>
#ifdef __WIN32__
#include <windows.h>
#endif /* __WIN32__ */

#include "nomuna.hpp"

using namespace std;

int main() {
#ifdef __WIN32__
    SetConsoleOutputCP(CP_UTF8);
#endif /* __WIN32__ */
    NimMain();
    noop();
    extraNoOp();
    int a = constRet();
    cout << a << endl;
    bool b = constRetBool();
    cout << b << endl;
    double c = constRetFloat();
    cout << c << endl;
    char d = constRetChar();
    cout << d << endl;
    const char* e = constRetStr();
    string f = e;
    cout << f << endl;
    const char* g = constRetUnicodeStr();
    string h = g;
    cout << h << endl;
    int i = addIntNum(5, 3);
    cout << i << endl;
    printCond(i == 8);
    printCond(i == 7);
    double j = addDouble(5.03, 3.05);
    cout << j << endl;
    float k = addFloat(5.3, 3.5);
    cout << k << endl;
    char l = 'a';
    takeChar(l);
    printStr("nim");
    printStr("hello ñíℳ"); // Unicode
    const char* m = sayHello("ñíℳ");
    string n = m;
    cout << n << endl;
    print2Str("Hello", "World!");
    Direction direction = Direction::South;
    printDirectionRawValue(direction);
    direction = getOpposite(Direction::North);
    cout << "Opposite of North: expected " << static_cast<int>(Direction::South) << ", got " << static_cast<int>(direction) << endl;
    direction = getDirection("south");
    cout << "Direction: " << static_cast<int>(direction) << endl;
    GameState gameState = GameState::Game_over;
    cout << "Game State: " << static_cast<int>(gameState) << endl;
    GameState newGameState = togglePause(gameState);
    cout << "Game State: " << static_cast<int>(newGameState) << endl;
    HttpStatusCode statusCode = authenticate("user1");
    cout << "Status code: " << static_cast<int>(statusCode) << endl;
    statusCode = setGameState("user", GameState::Game_over);
    cout << "set Game State result: " << static_cast<int>(statusCode) << endl;
    const char* newUser = requestPermission(FilePermission::Write);
    string nUser = newUser;
    cout << nUser << " has permission value: " << std::hex << std::showbase << std::internal << std::setw(4) << std::setfill('0') << static_cast<int>(FilePermission::Write) << endl;
    return 0;
}
