// SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
// SPDX-License-Identifier: GPL-2.0-or-later

pragma ComponentBehavior: Bound

import QtQuick
import org.kde.kirigamiaddons.settings as KirigamiSettings

KirigamiSettings.ConfigurationView {
    id: root

    modules: [
        KirigamiSettings.ConfigurationModule {
            icon.name: "preferences-system-symbolic"
            moduleId: "general"
            page: () => Qt.createComponent("org.kde.kirigamiapp1.settings", "GeneralPage")
            text: i18nc("@action:button", "General")
        }
    ]
}
