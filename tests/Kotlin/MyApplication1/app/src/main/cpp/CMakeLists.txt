# SPDX-FileCopyrightText: 2025 Rifat Hasan <atunutemp1@gmail.com>
#
# SPDX-License-Identifier: MIT

cmake_minimum_required(VERSION 3.22.1)

project("nomunaJNI")

add_library(${PROJECT_NAME} SHARED
        nomunaJNI.cpp nomuna.hpp)

find_library(log-lib log)
target_link_libraries(${PROJECT_NAME}
        ${CMAKE_CURRENT_LIST_DIR}/${ANDROID_ABI}/libnomuna.a
        android
        ${log-lib})
