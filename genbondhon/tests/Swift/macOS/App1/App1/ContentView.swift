// SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
//
// SPDX-License-Identifier: MIT

//
//  ContentView.swift
//  App1
//
//  Created by Atunu on 7/20/24.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var handler: ContentViewHandler
    
    init(handler: ContentViewHandler? = nil) {
        self.handler = handler ?? ContentViewHandler()
    }
    
    var body: some View {
        Grid(horizontalSpacing: 100) {
            GridRow(alignment: .top) {
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
                
                VStack(alignment: .leading) {
                    Text("Add")
                        .font(.largeTitle)
                    
                    HStack {
                        Text("Int:")
                            .frame(width: 50, alignment: .leading)
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
                            .frame(width: 50, alignment: .leading)
                        TextField("Number 1", value: $handler.addDouble1, format: FloatingPointFormatStyle<Double>.number)
                            .frame(width: 70)
                        Text("+")
                            .frame(width: 10)
                        TextField("Number 2", value: $handler.addDouble2, format: FloatingPointFormatStyle<Double>.number)
                            .frame(width: 70)
                        Text("=")
                            .frame(width: 10)
                        Text(String(handler.addDoubleRes))
                            .frame(width: 100, alignment: .leading)
                    }
                    
                    HStack {
                        Text("Float:")
                            .frame(width: 50, alignment: .leading)
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
                            .frame(width: 50, alignment: .leading)
                        TextField("Name", text: $handler.sayHelloInput)
                            .frame(width: 140)
                        Text(":")
                            .frame(width: 10)
                        Text(handler.sayHelloOutput)
                            .frame(width: 200, alignment: .leading)
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
