// SPDX-FileCopyrightText: 2025 Rifat Hasan <atunutemp1@gmail.com>
//
// SPDX-License-Identifier: MIT

//
//  ContentView.swift
//  MyApp1
//
//  Created by Atunu on 1/1/25.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var handler: ContentViewHandler

    init(handler: ContentViewHandler? = nil) {
        self.handler = handler ?? ContentViewHandler()
    }

    var body: some View {
        Grid(alignment: .topLeading, verticalSpacing: 50) {
            GridRow {
                VStack(alignment: .leading) {
                    Text("Constant Returns")
                        .font(.largeTitle)
                        .padding([.bottom], 10)

                    Text("Int: \(constRet())")
                    Text("Bool: \(String(constRetBool()))")
                    Text("Double: \(constRetFloat())")
                    Text("Character: \(String(constRetChar()))")
                    Text("String: \(constRetStr())")
                    Text("Unicode String: \(constRetUnicodeStr())")
                }
            }

            GridRow {
                VStack(alignment: .leading) {
                    Text("Add")
                        .font(.largeTitle)

                    HStack {
                        Text("Int:")
                            .frame(alignment: .leading)
                        TextField("Number 1", value: $handler.addInt1, format: IntegerFormatStyle<Int>.number)
                            .frame(width: 70)
                        Text("+")
                            .frame(width: 10)
                        TextField("Number 2", value: $handler.addInt2, format: IntegerFormatStyle<Int>.number)
                            .frame(width: 70)
                        Text("=")
                            .frame(width: 10)
                        Text(String(handler.addIntRes))
                            .frame(width: 100, alignment: .leading)
                    }

                    HStack {
                        Text("Double:")
                            .frame(alignment: .leading)
                        TextField(
                            "Number 1",
                            value: $handler.addDouble1,
                            format: FloatingPointFormatStyle<Double>.number
                        )
                        .frame(width: 70)
                        Text("+")
                            .frame(width: 10)
                        TextField(
                            "Number 2",
                            value: $handler.addDouble2,
                            format: FloatingPointFormatStyle<Double>.number
                        )
                        .frame(width: 70)
                        Text("=")
                            .frame(width: 10)
                        Text(String(handler.addDoubleRes))
                            .frame(width: 100, alignment: .leading)
                    }

                    HStack {
                        Text("Float:")
                            .frame(alignment: .leading)
                        TextField("Number 1", value: $handler.addFloat1, format: FloatingPointFormatStyle<Float>.number)
                            .frame(width: 70)
                        Text("+")
                            .frame(width: 10)
                        TextField("Number 2", value: $handler.addFloat2, format: FloatingPointFormatStyle<Float>.number)
                            .frame(width: 70)
                        Text("=")
                            .frame(width: 10)
                        Text(String(handler.addFloatRes))
                            .frame(width: 100, alignment: .leading)
                    }

                    HStack {
                        Text("String:")
                            .frame(alignment: .leading)
                        TextField("Name", text: $handler.sayHelloInput)
                            .frame(width: 80)
                        Text(":")
                            .frame(width: 10)
                        Text(handler.sayHelloOutput)
                            .frame(width: 160, alignment: .leading)
                    }
                }
            }
        }
        .padding(10)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
