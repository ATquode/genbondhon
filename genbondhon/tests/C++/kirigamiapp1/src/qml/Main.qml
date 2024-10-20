
// SPDX-License-Identifier: GPL-2.0-or-later
// SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts

import org.kde.kirigami as Kirigami
import org.kde.kirigamiaddons.statefulapp as StatefulApp
import org.kde.kirigamiaddons.formcard as FormCard

import org.kde.kirigamiapp1
import org.kde.kirigamiapp1.settings as Settings

StatefulApp.StatefulWindow {
    id: root

    property int counter: 0

    title: i18nc("@title:window", "KirigamiApp1")

    windowName: "KirigamiApp1"

    minimumWidth: Kirigami.Units.gridUnit * 20
    minimumHeight: Kirigami.Units.gridUnit * 20

    application: KirigamiApp1Application {
        configurationView: Settings.KirigamiApp1ConfigurationView {}
    }

    Connections {
        target: root.application

        function onIncrementCounter(): void {
            root.counter += 1
        }
    }

    Component.onCompleted: {
        libTestAction.trigger()
    }

    Kirigami.PagePool {
        id: appPagePool
    }

    readonly property list<Kirigami.PagePoolAction> navActions: [
        Kirigami.PagePoolAction {
            id: libTestAction
            text: i18n("Lib Testing")
            pagePool: appPagePool
            page: "LibTesting.qml"
        },
        Kirigami.PagePoolAction {
            id: counterAction
            text: i18n("Counter")
            pagePool: appPagePool
            page: "Incrementer.qml"
        }
    ]

    globalDrawer: Kirigami.GlobalDrawer {
        isMenu: !Kirigami.Settings.isMobile
        actions: [
            Kirigami.Action {
                id: incrementCounterAction
                enabled: navTabBar.currentIndex == 1
                fromQAction: root.application.action("increment_counter")
            },
            Kirigami.Action {
                separator: true
            },
            Kirigami.Action {
                fromQAction: root.application.action("options_configure")
            },
            Kirigami.Action {
                fromQAction: root.application.action(
                                 "options_configure_keybinding")
            },
            Kirigami.Action {
                separator: true
            },
            Kirigami.Action {
                id: aboutAction
                fromQAction: root.application.action("open_about_page")
            },
            Kirigami.Action {
                fromQAction: root.application.action("open_about_kde_page")
            },
            Kirigami.Action {
                fromQAction: root.application.action("file_quit")
            }
        ]
    }

    footer: navTabBar

    Kirigami.NavigationTabBar {
        id: navTabBar
        actions: navActions
    }
}
