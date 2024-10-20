# SPDX-License-Identifier: BSD-2-Clause
# SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>

add_subdirectory(settings)

qt_add_library(kirigamiapp1_static STATIC)
ecm_add_qml_module(kirigamiapp1_static
    URI org.kde.kirigamiapp1
    GENERATE_PLUGIN_SOURCE
    VERSION 1.0
    QML_FILES
        qml/Main.qml
		qml/LibTesting.qml
		qml/Incrementer.qml
    DEPENDENCIES
        org.kde.kirigamiaddons.formcard
        org.kde.kirigamiaddons.statefulapp
        org.kde.kirigami
        org.kde.kirigamiapp1.settings
)

target_sources(kirigamiapp1_static PUBLIC
    kirigamiapp1application.cpp
    kirigamiapp1application.h
	datamanager.h
	datamanager.cpp
	nomuna.hpp
)

target_link_libraries(kirigamiapp1_static PUBLIC
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::Svg
    KF6::I18n
    KF6::CoreAddons
    KF6::ConfigCore
    KF6::ConfigGui
    KirigamiAddonsStatefulApp
	${CMAKE_CURRENT_LIST_DIR}/libnomuna.a
)
target_include_directories(kirigamiapp1_static PUBLIC ${CMAKE_BINARY_DIR})

if (ANDROID)
    kirigami_package_breeze_icons(ICONS
        list-add
        help-about
        application-exit
        applications-graphics
    )
else()
    target_link_libraries(kirigamiapp1_static PUBLIC Qt::Widgets)
endif()

kconfig_add_kcfg_files(kirigamiapp1_static GENERATE_MOC kirigamiapp1config.kcfgc)

add_executable(kirigamiapp1 main.cpp)
target_link_libraries(kirigamiapp1 PUBLIC
    kirigamiapp1_static
    kirigamiapp1_staticplugin
    kirigamiapp1_settings
    kirigamiapp1_settingsplugin
)
install(TARGETS kirigamiapp1 ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
