// SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
//
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kirigamiaddons.formcard as FormCard

FormCard.FormCardPage {
    id: incrementerPage

    actions: [incrementCounterAction]
    title: i18nc("@title", "KirigamiApp1")

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
        text: i18nc("@title", "Welcome to KirigamiApp1") + '\n' + i18nc("@info:status", "Counter: %1", root.counter)
    }

    FormCard.FormCard {
        Layout.topMargin: Kirigami.Units.largeSpacing * 4

        FormCard.FormButtonDelegate {
            action: incrementCounterAction
        }

        FormCard.FormDelegateSeparator {
        }

        FormCard.FormButtonDelegate {
            action: aboutAction
        }
    }
}
