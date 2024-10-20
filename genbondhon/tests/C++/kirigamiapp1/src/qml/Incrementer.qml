// SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
//
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kirigamiaddons.formcard as FormCard

FormCard.FormCardPage {
	id: incrementerPage

	title: i18nc("@title", "KirigamiApp1")

	actions: [incrementCounterAction]

	Kirigami.Icon {
		source: "applications-development"
		implicitWidth: Math.round(Kirigami.Units.iconSizes.huge * 1.5)
		implicitHeight: Math.round(Kirigami.Units.iconSizes.huge * 1.5)

		Layout.alignment: Qt.AlignHCenter
		Layout.topMargin: Kirigami.Units.largeSpacing * 4
	}

	Kirigami.Heading {
		text: i18nc("@title", "Welcome to KirigamiApp1") + '\n' + i18nc("@info:status", "Counter: %1", root.counter)
		horizontalAlignment: Qt.AlignHCenter

		Layout.topMargin: Kirigami.Units.largeSpacing
		Layout.fillWidth: true
	}

	FormCard.FormCard {
		Layout.topMargin: Kirigami.Units.largeSpacing * 4

		FormCard.FormButtonDelegate {
			action: incrementCounterAction
		}

		FormCard.FormDelegateSeparator {}

		FormCard.FormButtonDelegate {
			action: aboutAction
		}
	}
}
