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
            header: Kirigami.Heading {
                text: qsTr("Constant Returns")
            }

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
                    text: qsTr(
                              "Unicode String: " + DataManager.unicodeStrRetVal)
                }
            }
        }

        Kirigami.Card {
            Layout.preferredWidth: (libTestingPage.width - 10) / 2
            header: Kirigami.Heading {
                text: qsTr("Add")
            }

            contentItem: ColumnLayout {
                RowLayout {
                    spacing: 10
                    QQC2.Label {
                        text: qsTr("Int:")
                    }
                    CommonTextField {
                        id: int1TextField
                        validator: IntValidator {}
                    }
                    QQC2.Label {
                        text: qsTr("+")
                    }
                    CommonTextField {
                        id: int2TextField
                        validator: IntValidator {}
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
            }
        }
    }

    component CommonTextField: Kirigami.ActionTextField {
        id: textField
        Layout.preferredWidth: 100
        rightActions: [
            Kirigami.Action {
                icon.name: "edit-clear"
                visible: textField.text !== ""
                onTriggered: {
                    textField.text = ""
                    textField.accepted()
                }
            }
        ]
    }

    Binding {
        target: DataManager
        property: "addInt1"
        value: int1TextField.text
    }

    Binding {
        target: DataManager
        property: "addInt2"
        value: int2TextField.text
    }

    Binding {
        target: DataManager
        property: "addDouble1"
        value: double1TextField.text
    }

    Binding {
        target: DataManager
        property: "addDouble2"
        value: double2TextField.text
    }

    Binding {
        target: DataManager
        property: "addFloat1"
        value: float1TextField.text
    }

    Binding {
        target: DataManager
        property: "addFloat2"
        value: float2TextField.text
    }

    Binding {
        target: DataManager
        property: "sayHelloInput"
        value: strTextField.text
    }
}
