# SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
# SPDX-License-Identifier: BSD-3-Clause

cmake_minimum_required(VERSION 3.16)

project(kirigamiapp1 VERSION 0.1)

include(FeatureSummary)

set(QT6_MIN_VERSION 6.5.0)
set(KF6_MIN_VERSION 6.0.0)
set(KIRIGAMI_ADDONS_MIN_VERSION 1.2.40)

find_package(ECM ${KF6_MIN_VERSION} REQUIRED NO_MODULE)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${ECM_MODULE_PATH})

include(FeatureSummary)

include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDECompilerSettings NO_POLICY_SCOPE)

include(ECMSetupVersion)
include(ECMFindQmlModule)
include(ECMQmlModule)
include(ECMQmlModule)

if(NOT ANDROID)
  include(KDEGitCommitHooks)
  include(KDEClangFormat)
endif()

ecm_setup_version(
  ${PROJECT_VERSION} VARIABLE_PREFIX KIRIGAMIAPP1 VERSION_HEADER
  "${CMAKE_CURRENT_BINARY_DIR}/src/version-kirigamiapp1.h")

set(QT_EXTRA_COMPONENTS)
if(NOT ANDROID)
  list(APPEND QT_EXTRA_COMPONENTS Widgets)
endif()

find_package(Qt6 ${QT6_MIN_VERSION} REQUIRED
             COMPONENTS Core Gui Qml QuickControls2 Svg ${QT_EXTRA_COMPONENTS})
find_package(KF6 ${KF6_MIN_VERSION} REQUIRED COMPONENTS Kirigami CoreAddons
                                                        Config I18n)

find_package(KF6KirigamiAddons ${KIRIGAMI_ADDONS_MIN_VERSION} REQUIRED)
set_package_properties(
  KF6KirigamiAddons PROPERTIES
  TYPE REQUIRED
  PURPOSE "Required application components and runtime dependency")

qt_policy(SET QTP0001 NEW)

ecm_find_qmlmodule(org.kde.kirigamiaddons.formcard)
ecm_find_qmlmodule(org.kde.kirigamiaddons.statefulapp)

if(ANDROID)
  configure_file(${CMAKE_CURRENT_SOURCE_DIR}/android/version.gradle.in
                 ${CMAKE_BINARY_DIR}/version.gradle)
endif()

add_subdirectory(src)

install(FILES org.kde.kirigamiapp1.desktop DESTINATION ${KDE_INSTALL_APPDIR})
install(FILES org.kde.kirigamiapp1.metainfo.xml
        DESTINATION ${KDE_INSTALL_METAINFODIR})
ki18n_install(po)

feature_summary(WHAT ALL INCLUDE_QUIET_PACKAGES
                         FATAL_ON_MISSING_REQUIRED_PACKAGES)

if(NOT ANDROID)
  file(GLOB_RECURSE ALL_CLANG_FORMAT_SOURCE_FILES src/*.cpp src/*.h)
  kde_clang_format(${ALL_CLANG_FORMAT_SOURCE_FILES})
  kde_configure_git_pre_commit_hook(CHECKS CLANG_FORMAT)
endif()
