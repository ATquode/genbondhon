// SPDX-FileCopyrightText: 2025 Rifat Hasan <atunutemp1@gmail.com>
//
// SPDX-License-Identifier: MIT

@file:Suppress("TooManyFunctions", "MagicNumber")

package com.example.myapplication1

class Nomuna {
    enum class Direction {
        NORTH,
        EAST,
        SOUTH,
        WEST
    }

    enum class GameState(val intVal: Int) {
        PLAYING(100),
        PAUSE(101),
        GAME_OVER(102)
    }

    enum class HttpStatusCode(val intVal: Int) {
        OK(200),
        CREATED(201),
        NO_CONTENT(204),
        MOVED_PERMANENTLY(301),
        FOUND(302),
        NOT_MODIFIED(304),
        BAD_REQUEST(400),
        UNAUTHORIZED(401),
        FORBIDDEN(403),
        NOT_FOUND(404),
        INTERNAL_SERVER_ERROR(500),
        BAD_GATEWAY(502),
        SERVICE_UNAVAILABLE(503)
    }

    external fun nimMain()

    external fun noop()

    external fun extraNoOp()

    external fun constRet(): Int

    external fun constRetBool(): Boolean

    external fun constRetFloat(): Double

    external fun constRetChar(): Char

    external fun constRetStr(): String

    external fun constRetUnicodeStr(): String

    external fun addIntNum(a: Int, b: Int): Int

    external fun printCond(a: Boolean)

    external fun addDouble(a: Double, b: Double): Double

    external fun addFloat(a: Float, b: Float): Float

    external fun takeChar(a: Char)

    external fun printStr(a: String)

    external fun sayHello(name: String): String

    external fun print2Str(str1: String, str2: String)

    fun printDirectionRawValue(direction: Direction) {
        printDirectionRawValueVal(direction.ordinal)
    }

    private external fun printDirectionRawValueVal(direction: Int)

    fun getDirection(hint: String): Direction {
        val data = getDirectionVal(hint)
        return Direction.entries[data]
    }

    private external fun getDirectionVal(hint: String): Int

    fun getOpposite(direction: Direction): Direction {
        val data = getOppositeVal(direction.ordinal)
        return Direction.entries[data]
    }

    private external fun getOppositeVal(direction: Int): Int

    fun togglePause(curState: GameState): GameState {
        val data = togglePauseVal(curState.intVal)
        return GameState.entries.first { it.intVal == data }
    }

    private external fun togglePauseVal(curState: Int): Int

    fun authenticate(username: String): HttpStatusCode {
        val data = authenticateVal(username)
        return HttpStatusCode.entries.first { it.intVal == data }
    }

    private external fun authenticateVal(username: String): Int

    fun setGameState(username: String, state: GameState): HttpStatusCode {
        val data = setGameStateVal(username, state.intVal)
        return HttpStatusCode.entries.first { it.intVal == data }
    }

    private external fun setGameStateVal(username: String, state: Int): Int

    companion object {
        init {
            System.loadLibrary("nomunaJNI")
        }
    }
}
