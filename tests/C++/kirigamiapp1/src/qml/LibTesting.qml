// SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
//
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

import org.kde.kirigamiapp1

Kirigami.ScrollablePage {
    id: libTestingPage

    Kirigami.CardsLayout {
        Kirigami.Card {
            Layout.preferredWidth: (libTestingPage.width - 10) / 2

            contentItem: ColumnLayout {
                QQC2.Label {
                    text: qsTr("Int: " + DataManager.intRetVal)
                }

                QQC2.Label {
                    text: qsTr("Bool: " + DataManager.boolRetVal)
                }

                QQC2.Label {
                    text: qsTr("Double: " + DataManager.doubleRetVal)
                }

                QQC2.Label {
                    text: qsTr("Char: " + DataManager.charRetVal)
                }

                QQC2.Label {
                    text: qsTr("String: " + DataManager.strRetVal)
                }

                QQC2.Label {
                    text: qsTr("Unicode String: " + DataManager.unicodeStrRetVal)
                }
            }
            header: Kirigami.Heading {
                text: qsTr("Constant Returns")
            }
        }

        Kirigami.Card {
            Layout.preferredWidth: (libTestingPage.width - 10) / 2

            contentItem: ColumnLayout {
                RowLayout {
                    spacing: 10

                    QQC2.Label {
                        text: qsTr("Int:")
                    }

                    CommonTextField {
                        id: int1TextField

                        validator: IntValidator {
                        }
                    }

                    QQC2.Label {
                        text: qsTr("+")
                    }

                    CommonTextField {
                        id: int2TextField

                        validator: IntValidator {
                        }
                    }

                    QQC2.Label {
                        text: qsTr("=")
                    }

                    QQC2.Label {
                        text: DataManager.addIntRes
                    }
                }

                RowLayout {
                    spacing: 10

                    QQC2.Label {
                        text: qsTr("Double:")
                    }

                    CommonTextField {
                        id: double1TextField

                        validator: DoubleValidator {
                            decimals: 4
                        }
                    }

                    QQC2.Label {
                        text: qsTr("+")
                    }

                    CommonTextField {
                        id: double2TextField

                        validator: DoubleValidator {
                            decimals: 4
                        }
                    }

                    QQC2.Label {
                        text: qsTr("=")
                    }

                    QQC2.Label {
                        text: DataManager.addDoubleRes.toFixed(4)
                    }
                }

                RowLayout {
                    spacing: 10

                    QQC2.Label {
                        text: qsTr("Float:")
                    }

                    CommonTextField {
                        id: float1TextField

                        validator: DoubleValidator {
                            decimals: 2
                        }
                    }

                    QQC2.Label {
                        text: qsTr("+")
                    }

                    CommonTextField {
                        id: float2TextField

                        validator: DoubleValidator {
                            decimals: 2
                        }
                    }

                    QQC2.Label {
                        text: qsTr("=")
                    }

                    QQC2.Label {
                        text: DataManager.addFloatRes.toFixed(2)
                    }
                }
            }
            header: Kirigami.Heading {
                text: qsTr("Add")
            }
        }

        Kirigami.Card {
            contentItem: ColumnLayout {
                RowLayout {
                    QQC2.Label {
                        text: qsTr("String:")
                    }

                    CommonTextField {
                        id: strTextField

                    }

                    QQC2.Label {
                        text: qsTr(":")
                    }

                    QQC2.Label {
                        text: DataManager.sayHelloOutput
                    }
                }

                RowLayout {
                    QQC2.Label {
                        text: qsTr("Direction:")
                    }

                    QQC2.ComboBox {
                        id: dirComboBox

                        model: directionModel
                        textRole: directionModel.textRole
                        valueRole: directionModel.valueRole
                    }

                    QQC2.Label {
                        text: qsTr("Opposite: " + directionModel.oppositeDirection)
                    }
                }
            }
            header: Kirigami.Heading {
                text: qsTr("Input")
            }
        }
    }

    DirectionModel {
        id: directionModel

    }

    Binding {
        property: "addInt1"
        target: DataManager
        value: int1TextField.text
    }

    Binding {
        property: "addInt2"
        target: DataManager
        value: int2TextField.text
    }

    Binding {
        property: "addDouble1"
        target: DataManager
        value: double1TextField.text
    }

    Binding {
        property: "addDouble2"
        target: DataManager
        value: double2TextField.text
    }

    Binding {
        property: "addFloat1"
        target: DataManager
        value: float1TextField.text
    }

    Binding {
        property: "addFloat2"
        target: DataManager
        value: float2TextField.text
    }

    Binding {
        property: "sayHelloInput"
        target: DataManager
        value: strTextField.text
    }

    Binding {
        property: "selectedDirection"
        target: directionModel
        value: dirComboBox.currentValue
    }

    component CommonTextField: Kirigami.ActionTextField {
        id: textField

        Layout.preferredWidth: 100

        rightActions: [
            Kirigami.Action {
                icon.name: "edit-clear"
                visible: textField.text !== ""

                onTriggered: {
                    textField.text = "";
                    textField.accepted();
                }
            }
        ]
    }
}
