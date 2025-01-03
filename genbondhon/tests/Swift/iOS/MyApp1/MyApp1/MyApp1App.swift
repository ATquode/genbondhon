// SPDX-FileCopyrightText: 2025 Rifat Hasan <atunutemp1@gmail.com>
//
// SPDX-License-Identifier: MIT

//
//  MyApp1App.swift
//  MyApp1
//
//  Created by Atunu on 1/1/25.
//

import SwiftUI

@main
struct MyApp1App: App {
    var contentViewHandler: ContentViewHandler

    init() {
        NimMain()
        noop()
        extraNoOp()
        contentViewHandler = ContentViewHandler()
    }

    var body: some Scene {
        WindowGroup {
            ContentView(handler: contentViewHandler)
        }
    }
}
