// SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
//
// SPDX-License-Identifier: MIT

package com.example.myapplication1

import android.util.Log
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.ViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update

class MainViewModel : ViewModel() {
    val nomuna = Nomuna()
    val inputHolder = InputHolder()

    init {
        nomuna.nimMain()
        nomuna.noop()
        nomuna.extraNoOp()
        nomuna.printCond(inputHolder.addInt1 == "")
        nomuna.printCond(inputHolder.addInt1 != "")
        nomuna.takeChar('a')
        nomuna.printStr("nim")
        nomuna.printStr("hello ñíℳ")
        nomuna.print2Str("Hello", "World!")
        var direction = Nomuna.Direction.SOUTH
        nomuna.printDirectionRawValue(direction)
        direction = nomuna.getDirection("south")
        Log.d("nomuna", "Direction: $direction, value: ${direction.ordinal}")
        val gameState = Nomuna.GameState.GAME_OVER
        Log.d("nomuna", "Game State: $gameState, value: ${gameState.intVal}")
        val newGameState = nomuna.togglePause(gameState)
        Log.d("nomuna", "Game State: $newGameState, value: ${newGameState.intVal}")
        var statusCode = nomuna.authenticate("user1")
        Log.d("nomuna", "Status code: $statusCode, value: ${statusCode.intVal}")
        statusCode = nomuna.setGameState("user", Nomuna.GameState.GAME_OVER)
        Log.d("nomuna", "set Game State result: $statusCode, value: ${statusCode.intVal}")
        val newUser = nomuna.requestPermission(Nomuna.FilePermission.WRITE)
        Log.d("nomuna", "$newUser has permission: ${Nomuna.FilePermission.WRITE}")
    }

    val retCardUiState =
        ReturnCardUiState(
            nomuna.constRet(),
            nomuna.constRetBool(),
            nomuna.constRetFloat(),
            nomuna.constRetChar(),
            nomuna.constRetStr(),
            nomuna.constRetUnicodeStr(),
        )

    private var _addCardUiState = MutableStateFlow(AddCardUiState())
    val addCardUiState: StateFlow<AddCardUiState> = _addCardUiState.asStateFlow()

    private var _inputCardUiState =
        MutableStateFlow(
            InputCardUiState(
                oppositeDirection = nomuna.getOpposite(Nomuna.Direction.entries.first()).name,
            ),
        )
    val inputCardUiState: StateFlow<InputCardUiState> = _inputCardUiState.asStateFlow()

    inner class InputHolder : InputContainer {
        override var addInt1 by mutableStateOf("")
            private set
        override var addInt2 by mutableStateOf("")
            private set
        override var addDouble1 by mutableStateOf("")
            private set
        override var addDouble2 by mutableStateOf("")
            private set
        override var addFloat1 by mutableStateOf("")
            private set
        override var addFloat2 by mutableStateOf("")
            private set
        override var sayHelloInput by mutableStateOf("")
            private set

        override fun updateIntNum1(num: String) {
            if (!verifyIntOrEmpty(num)) {
                return
            }
            addInt1 = num
            performAddInt()
        }

        override fun updateIntNum2(num: String) {
            if (!verifyIntOrEmpty(num)) {
                return
            }
            addInt2 = num
            performAddInt()
        }

        override fun updateDoubleNum1(num: String) {
            if (!verifyDoubleOrEmpty(num)) {
                return
            }
            addDouble1 = num
            performAddDouble()
        }

        override fun updateDoubleNum2(num: String) {
            if (!verifyDoubleOrEmpty(num)) {
                return
            }
            addDouble2 = num
            performAddDouble()
        }

        override fun updateFloatNum1(num: String) {
            if (!verifyFloatOrEmpty(num)) {
                return
            }
            addFloat1 = num
            performAddFloat()
        }

        override fun updateFloatNum2(num: String) {
            if (!verifyFloatOrEmpty(num)) {
                return
            }
            addFloat2 = num
            performAddFloat()
        }

        override fun updateStrInput(str: String) {
            sayHelloInput = str
            performSayHello()
        }

        override fun updateSelectedDirection(direction: String) {
            performDirectionSelection(direction)
        }
    }

    private fun verifyIntOrEmpty(num: String): Boolean = num.toIntOrNull() != null || num.isEmpty()

    private fun verifyDoubleOrEmpty(num: String): Boolean = num.toDoubleOrNull() != null || num.isEmpty()

    private fun verifyFloatOrEmpty(num: String): Boolean =
        (
            num.toFloatOrNull() != null &&
                (if (num.contains('.')) num.substring(num.indexOf('.') + 1).length <= 2 else true)
        ) ||
            num.isEmpty()

    private fun performAddInt() {
        val num1 = inputHolder.addInt1.toIntOrNull() ?: 0
        val num2 = inputHolder.addInt2.toIntOrNull() ?: 0
        _addCardUiState.update { currentState ->
            currentState.copy(addIntRes = nomuna.addIntNum(num1, num2).toString())
        }
    }

    private fun performAddDouble() {
        val num1 = inputHolder.addDouble1.toDoubleOrNull() ?: 0.0
        val num2 = inputHolder.addDouble2.toDoubleOrNull() ?: 0.0
        _addCardUiState.update { currentState ->
            currentState.copy(addDoubleRes = "%.4f".format(nomuna.addDouble(num1, num2)))
        }
    }

    private fun performAddFloat() {
        val num1 = inputHolder.addFloat1.toFloatOrNull() ?: 0.0f
        val num2 = inputHolder.addFloat2.toFloatOrNull() ?: 0.0f
        _addCardUiState.update { currentState ->
            currentState.copy(addFloatRes = "%.2f".format(nomuna.addFloat(num1, num2)))
        }
    }

    private fun performSayHello() {
        _inputCardUiState.update { currentState ->
            currentState.copy(sayHelloOutput = nomuna.sayHello(inputHolder.sayHelloInput))
        }
    }

    private fun performDirectionSelection(direction: String) {
        val selectedDirection = Nomuna.Direction.entries.first { it.name == direction }
        val oppositeDirection = nomuna.getOpposite(selectedDirection)
        _inputCardUiState.update { currentState ->
            currentState.copy(oppositeDirection = oppositeDirection.name)
        }
    }
}

interface InputContainer {
    val addInt1: String

    fun updateIntNum1(num: String)

    val addInt2: String

    fun updateIntNum2(num: String)

    val addDouble1: String

    fun updateDoubleNum1(num: String)

    val addDouble2: String

    fun updateDoubleNum2(num: String)

    val addFloat1: String

    fun updateFloatNum1(num: String)

    val addFloat2: String

    fun updateFloatNum2(num: String)

    val sayHelloInput: String

    fun updateStrInput(str: String)

    fun updateSelectedDirection(direction: String)
}
