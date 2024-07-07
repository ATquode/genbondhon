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
    int f = addInt(5, 3);
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
    return 0;
}
