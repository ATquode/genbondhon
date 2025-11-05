// SPDX-FileCopyrightText: 2025 Rifat Hasan <atunutemp1@gmail.com>
//
// SPDX-License-Identifier: MIT

#ifndef NOMUNA_HPP
#define NOMUNA_HPP

extern "C" {
    enum class Direction {
        North,
        East,
        South,
        West
    };

    enum class GameState {
        Playing = 100,
        Pause,
        Game_over
    };

    enum class HttpStatusCode {
        Ok = 200,
        Created,
        No_content = 204,
        Moved_permanently = 301,
        Found,
        Not_modified = 304,
        Bad_request = 400,
        Unauthorized,
        Forbidden = 403,
        Not_found,
        Internal_server_error = 500,
        Bad_gateway = 502,
        Service_unavailable
    };

    void NimMain();

    void noop();

    void extraNoOp();

    int constRet();

    bool constRetBool();

    double constRetFloat();

    char constRetChar();

    const char* constRetStr();

    const char* constRetUnicodeStr();

    int addIntNum(int a, int b);

    void printCond(bool a);

    double addDouble(double a, double b);

    float addFloat(float a, float b);

    void takeChar(char a);

    void printStr(const char* a);

    const char* sayHello(const char* name);

    void print2Str(const char* str1, const char* str2);

    void printDirectionRawValue(Direction direction);

    Direction getDirection(const char* hint);

    Direction getOpposite(Direction direction);

    GameState togglePause(GameState curState);

    HttpStatusCode authenticate(const char* username);

    HttpStatusCode setGameState(const char* username, GameState state);
}

#endif /* NOMUNA_HPP */
