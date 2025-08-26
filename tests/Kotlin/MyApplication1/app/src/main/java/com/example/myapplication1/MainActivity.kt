// SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
//
// SPDX-License-Identifier: MIT

package com.example.myapplication1

import android.content.res.Configuration
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.Card
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.ExposedDropdownMenuBox
import androidx.compose.material3.ExposedDropdownMenuDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.tooling.preview.Wallpapers
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import com.example.myapplication1.ui.theme.MyApplication1Theme

private val directionPickerOptions = Nomuna.Direction.entries.map { it.name }

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            MainView()
        }
    }
}

@Composable
fun MainView(mainViewModel: MainViewModel = viewModel<MainViewModel>()) {
    val addCardUiState by mainViewModel.addCardUiState.collectAsState()
    val inputCardUiState by mainViewModel.inputCardUiState.collectAsState()
    MainContent(
        mainViewModel.retCardUiState,
        addCardUiState,
        inputCardUiState,
        mainViewModel.inputHolder,
    )
}

@Composable
fun MainContent(
    returnCardUiState: ReturnCardUiState,
    addCardUiState: AddCardUiState,
    inputCardUiState: InputCardUiState,
    inputVars: InputContainer,
) {
    MyApplication1Theme {
        Scaffold(modifier = Modifier.fillMaxSize()) { innerPadding ->
            Column(
                modifier =
                    Modifier
                        .fillMaxSize()
                        .padding(innerPadding),
            ) {
                ConstantReturnListCard(
                    modifier =
                        Modifier
                            .padding(10.dp)
                            .fillMaxWidth(),
                    uiState = returnCardUiState,
                )
                AddListCard(
                    modifier =
                        Modifier
                            .padding(10.dp)
                            .fillMaxWidth(),
                    uiState = addCardUiState,
                    inputVars = inputVars,
                )
                InputListCard(
                    modifier =
                        Modifier
                            .padding(10.dp)
                            .fillMaxWidth(),
                    uiState = inputCardUiState,
                    inputVars = inputVars,
                )
            }
        }
    }
}

@Composable
fun ConstantReturnListCard(
    modifier: Modifier = Modifier,
    uiState: ReturnCardUiState,
) {
    CardView(modifier) {
        Text(text = "Constant Returns", style = MaterialTheme.typography.titleLarge)
        Text(text = "Int: ${uiState.intRetVal}")
        Text(text = "Bool: ${uiState.boolRetVal}")
        Text(text = "Double: ${uiState.doubleRetVal}")
        Text(text = "Character: ${uiState.charRetVal}")
        Text(text = "String: ${uiState.stringRetVal}")
        Text(text = "Unicode String: ${uiState.unicodeStringRetVal}")
    }
}

@Composable
fun AddListCard(
    modifier: Modifier,
    uiState: AddCardUiState,
    inputVars: InputContainer,
) {
    CardView(modifier) {
        Text(text = "Add", style = MaterialTheme.typography.titleLarge)
        AddRow(
            labelStr = "Int:",
            addResult = uiState.addIntRes,
            addNum1 = inputVars.addInt1,
            updateNum1 = inputVars::updateIntNum1,
            addNum2 = inputVars.addInt2,
            updateNum2 = inputVars::updateIntNum2,
        )
        AddRow(
            labelStr = "Double:",
            addResult = uiState.addDoubleRes,
            addNum1 = inputVars.addDouble1,
            updateNum1 = inputVars::updateDoubleNum1,
            addNum2 = inputVars.addDouble2,
            updateNum2 = inputVars::updateDoubleNum2,
        )
        AddRow(
            labelStr = "Float:",
            addResult = uiState.addFloatRes,
            addNum1 = inputVars.addFloat1,
            updateNum1 = inputVars::updateFloatNum1,
            addNum2 = inputVars.addFloat2,
            updateNum2 = inputVars::updateFloatNum2,
        )
    }
}

@Composable
fun InputListCard(
    modifier: Modifier,
    uiState: InputCardUiState,
    inputVars: InputContainer,
) {
    CardView(modifier) {
        Text(text = "Input", style = MaterialTheme.typography.titleLarge)
        SayHelloRow(
            outputStr = uiState.sayHelloOutput,
            inputStr = inputVars.sayHelloInput,
            updateInputStr = inputVars::updateStrInput,
        )
        Row(
            modifier = Modifier.padding(10.dp),
            horizontalArrangement = Arrangement.spacedBy(10.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Text(text = "Direction:")
            DirectionDropDownMenuBox(inputVars::updateSelectedDirection)
        }
        Row(
            horizontalArrangement = Arrangement.spacedBy(10.dp),
        ) {
            Text(text = "Opposite:")
            Text(text = uiState.oppositeDirection)
        }
    }
}

@Composable
fun CardView(
    modifier: Modifier,
    content: @Composable ColumnScope.() -> Unit,
) {
    Card(
        modifier = modifier,
    ) {
        Column(
            modifier = Modifier.padding(10.dp),
        ) {
            content()
        }
    }
}

@Composable
fun AddRow(
    labelStr: String,
    addResult: String,
    addNum1: String,
    updateNum1: (String) -> Unit,
    addNum2: String,
    updateNum2: (String) -> Unit,
) {
    Row(
        horizontalArrangement = Arrangement.spacedBy(10.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Text(text = labelStr)
        OutlinedTextField(
            value = addNum1,
            onValueChange = updateNum1,
            label = {
                Text(text = "Number 1")
            },
            modifier = Modifier.weight(1f),
            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
        )
        Text(text = "+")
        OutlinedTextField(
            value = addNum2,
            onValueChange = updateNum2,
            label = {
                Text(text = "Number 2")
            },
            modifier = Modifier.weight(1f),
            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
        )
        Text(text = "=")
        Text(text = addResult)
    }
}

@Composable
fun SayHelloRow(
    outputStr: String,
    inputStr: String,
    updateInputStr: (String) -> Unit,
) {
    Row(
        horizontalArrangement = Arrangement.spacedBy(10.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Text(text = "String:")
        OutlinedTextField(
            value = inputStr,
            onValueChange = updateInputStr,
            label = {
                Text(text = "Name")
            },
            modifier = Modifier.weight(1f),
        )
        Text(text = ":")
        Text(text = outputStr)
    }
}

@Composable
@OptIn(ExperimentalMaterial3Api::class, ExperimentalFoundationApi::class)
fun DirectionDropDownMenuBox(updateSelection: (String) -> Unit) {
    var isExpanded by remember { mutableStateOf(false) }
    var selectedValue by remember { mutableStateOf(directionPickerOptions[0]) }
    ExposedDropdownMenuBox(expanded = isExpanded, onExpandedChange = {
        isExpanded = !isExpanded
    }) {
        OutlinedTextField(
            value = selectedValue,
            onValueChange = { },
            readOnly = true,
            trailingIcon = {
                ExposedDropdownMenuDefaults.TrailingIcon(expanded = isExpanded)
            },
            modifier = Modifier.menuAnchor().fillMaxWidth(),
        )
        ExposedDropdownMenu(expanded = isExpanded, onDismissRequest = { isExpanded = false }) {
            directionPickerOptions.forEach { option ->
                DropdownMenuItem(
                    text = { Text(option) },
                    onClick = {
                        isExpanded = false
                        selectedValue = option
                        updateSelection(selectedValue)
                    },
                )
            }
        }
    }
}

@Preview(
    name = "Light-Blue",
    showBackground = true,
    wallpaper = Wallpapers.BLUE_DOMINATED_EXAMPLE,
)
@Preview(
    name = "Dark-Blue",
    showBackground = true,
    wallpaper = Wallpapers.BLUE_DOMINATED_EXAMPLE,
    uiMode = Configuration.UI_MODE_NIGHT_YES,
)
@Composable
fun GreetingPreview() {
    MainContent(
        ReturnCardUiState(2, false, 2.0, 'A', "str", "fe"),
        AddCardUiState(),
        InputCardUiState("", Nomuna.Direction.SOUTH.name),
        InputVars("", "", "", "", "", "", ""),
    )
}

data class InputVars(
    override val addInt1: String,
    override val addInt2: String,
    override val addDouble1: String,
    override val addDouble2: String,
    override val addFloat1: String,
    override val addFloat2: String,
    override val sayHelloInput: String,
) : InputContainer {
    override fun updateIntNum1(num: String) { /* no-op */ }

    override fun updateIntNum2(num: String) { /* no-op */ }

    override fun updateDoubleNum1(num: String) { /* no-op */ }

    override fun updateDoubleNum2(num: String) { /* no-op */ }

    override fun updateFloatNum1(num: String) { /* no-op */ }

    override fun updateFloatNum2(num: String) { /* no-op */ }

    override fun updateStrInput(str: String) { /* no-op */ }

    override fun updateSelectedDirection(direction: String) { /* no-op */ }
}
