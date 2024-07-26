// SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
//
// SPDX-License-Identifier: MIT

//
//  App1App.swift
//  App1
//
//  Created by Atunu on 7/20/24.
//

import SwiftUI

@main
struct App1App: App {
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
