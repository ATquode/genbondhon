// SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
//
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kirigamiaddons.formcard as FormCard
import org.kde.ki18n

FormCard.FormCardPage {
    id: incrementerPage

    required property Kirigami.Action aboutAction
    property int counter: 0
    required property Kirigami.Action incrementAction

    actions: [incrementAction]
    title: KI18n.i18nc("@title", "KirigamiApp1")

    Kirigami.Icon {
        Layout.alignment: Qt.AlignHCenter
        Layout.topMargin: Kirigami.Units.largeSpacing * 4
        implicitHeight: Math.round(Kirigami.Units.iconSizes.huge * 1.5)
        implicitWidth: Math.round(Kirigami.Units.iconSizes.huge * 1.5)
        source: "applications-development"
    }

    Kirigami.Heading {
        Layout.fillWidth: true
        Layout.topMargin: Kirigami.Units.largeSpacing
        horizontalAlignment: Qt.AlignHCenter
        text: KI18n.i18nc("@title", "Welcome to KirigamiApp1") + '\n' + KI18n.i18nc("@info:status", "Counter: %1", incrementerPage.counter)
    }

    FormCard.FormCard {
        Layout.topMargin: Kirigami.Units.largeSpacing * 4

        FormCard.FormButtonDelegate {
            action: incrementerPage.incrementAction
        }

        FormCard.FormDelegateSeparator {
        }

        FormCard.FormButtonDelegate {
            action: incrementerPage.aboutAction
        }
    }
}
