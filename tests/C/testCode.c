// SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
//
// SPDX-License-Identifier: MIT

#include <stdio.h>
#ifdef __WIN32__
#include <windows.h>
#endif /* __WIN32__ */

#include "nomuna.h"

int main() {
#ifdef __WIN32__
    SetConsoleOutputCP(CP_UTF8);
#endif /* __WIN32__ */
    NimMain();
    noop();
    extraNoOp();
    int a = constRet();
    printf("%d\n", a);
    bool b = constRetBool();
    printf("%d\n", b);
    double c = constRetFloat();
    printf("%lf\n", c);
    char d = constRetChar();
    printf("%c\n", d);
    const char* e = constRetStr();
    printf("%s\n", e);
    const char* j = constRetUnicodeStr();
    printf("%s\n", j);
    int f = addIntNum(5, 3);
    printf("%d\n", f);
    printCond(f == 8);
    printCond(f == 7);
    double g = addDouble(5.03, 3.05);
    printf("%lf\n", g);
    float h = addFloat(5.3, 3.5);
    printf("%f\n", h);
    char i = 'a';
    takeChar(i);
    printStr("nim");
    printStr("hello ñíℳ"); // Unicode
    const char* k = sayHello("ñíℳ");
    printf("%s\n", k);
    print2Str("Hello", "World!");
    Direction direction = SOUTH;
    printDirectionRawValue(direction);
    direction = getOpposite(NORTH);
    printf("Opposite of NORTH: expected %d, got %d\n", SOUTH, direction);
    direction = getDirection("south");
    printf("Direction: %d\n", direction);
    GameState gameState = GAME_OVER;
    printf("Game State: %d\n", gameState);
    GameState newGameState = togglePause(gameState);
    printf("Game State: %d\n", newGameState);
    HttpStatusCode statusCode = authenticate("user1");
    printf("Status code: %d\n", statusCode);
    statusCode = setGameState("user", GAME_OVER);
    printf("set Game State result: %d\n", statusCode);
    const char* newUser = requestPermission(WRITE);
    printf("%s has permission value: %#04x\n", newUser, WRITE);
    FilePermission permission = getLeastPriviledgedPermission();
    printf("Least priviledged permission value: %#04x\n", permission);
    bool reqRes = requestAccess(WRITE, "/");
    printf("Request access result: %d\n", reqRes);
    int l = addIntNum2(11, 14);
    printf("%d\n", l);
    Int2Tuple divRes = divMod(10, 3);
    printf("%d, %d\n", divRes.val1, divRes.val2);
    Int2Tuple position;
    position.val1 = 1;
    position.val2 = 2;
    Int3Tuple position3d = extendTo3D(position, 3);
    printf("%d, %d, %d\n", position3d.val1, position3d.val2, position3d.val3);
    position3d.val1 = 1;
    position3d.val2 = 2;
    position3d.val3 = 3;
    Int3Tuple newPosition3d = translate3D(position3d, -2);
    printf("%d, %d, %d\n", newPosition3d.val1, newPosition3d.val2, newPosition3d.val3);
    Float4Tuple quaternion;
    quaternion.val1 = 1.0;
    quaternion.val2 = -2.0;
    quaternion.val3 = 2.0;
    quaternion.val4 = 1.0;
    Float4Tuple inverseQuat = inverseQuaternion(quaternion);
    printf("%f, %f, %f, %f\n", inverseQuat.val1, inverseQuat.val2, inverseQuat.val3, inverseQuat.val4);
    return 0;
}
