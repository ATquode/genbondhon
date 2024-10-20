# SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
# SPDX-License-Identifier: BSD-2-Clause

qt_add_library(kirigamiapp1_settings STATIC)
ecm_add_qml_module(kirigamiapp1_settings
    GENERATE_PLUGIN_SOURCE
    URI org.kde.kirigamiapp1.settings
    QML_FILES
        KirigamiApp1ConfigurationView.qml
        GeneralPage.qml
)
