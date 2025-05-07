// SPDX-License-Identifier: GPL-2.0-or-later
// SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
import QtQuick

import org.kde.kirigami as Kirigami
import org.kde.kirigamiaddons.statefulapp as StatefulApp

import org.kde.kirigamiapp1
import org.kde.kirigamiapp1.settings as Settings

StatefulApp.StatefulWindow {
    id: root

    property int counter: 0
    readonly property list<Kirigami.PagePoolAction> navActions: [
        Kirigami.PagePoolAction {
            id: libTestAction

            page: "LibTesting.qml"
            pagePool: appPagePool
            text: i18n("Lib Testing")
        },
        Kirigami.PagePoolAction {
            id: counterAction

            page: "Incrementer.qml"
            pagePool: appPagePool
            text: i18n("Counter")
        }
    ]

    footer: navTabBar
    minimumHeight: Kirigami.Units.gridUnit * 20
    minimumWidth: Kirigami.Units.gridUnit * 20
    title: i18nc("@title:window", "KirigamiApp1")
    windowName: "KirigamiApp1"

    application: KirigamiApp1Application {
        configurationView: Settings.KirigamiApp1ConfigurationView {
        }
    }
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
                fromQAction: root.application.action("options_configure_keybinding")
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

    Component.onCompleted: {
        libTestAction.trigger();
    }

    Connections {
        function onIncrementCounter(): void {
            root.counter += 1;
        }

        target: root.application
    }

    Kirigami.PagePool {
        id: appPagePool

    }

    Kirigami.NavigationTabBar {
        id: navTabBar

        actions: root.navActions
    }
}
