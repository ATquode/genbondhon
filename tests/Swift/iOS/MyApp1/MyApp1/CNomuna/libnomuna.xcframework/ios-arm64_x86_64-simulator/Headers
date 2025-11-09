#ifndef NOMUNA_H
#define NOMUNA_H

#include <stdbool.h>

typedef enum {
    NORTH,
    EAST,
    SOUTH,
    WEST
} Direction;

typedef enum {
    PLAYING = 100,
    PAUSE,
    GAME_OVER
} GameState;

typedef enum {
    OK = 200,
    CREATED,
    NO_CONTENT = 204,
    MOVED_PERMANENTLY = 301,
    FOUND,
    NOT_MODIFIED = 304,
    BAD_REQUEST = 400,
    UNAUTHORIZED,
    FORBIDDEN = 403,
    NOT_FOUND,
    INTERNAL_SERVER_ERROR = 500,
    BAD_GATEWAY = 502,
    SERVICE_UNAVAILABLE
} HttpStatusCode;

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

#endif /* NOMUNA_H */
