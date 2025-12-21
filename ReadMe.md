<!--
SPDX-FileCopyrightText: 2025 Rifat Hasan <atunutemp1@gmail.com>

SPDX-License-Identifier: MIT
-->

`genbondhon` is a command line tool to generate binding for different languages from nim library.
It is inspired by [genny](https://github.com/treeform/genny), but focused on binding to platform native GUI technologies.

Binding for following languages & operating systems are currently tested.

| Language   | Operating System      |
| ---------- | --------------------- |
| C          | Windows, macOS, Linux |
| C++        | Windows, macOS, Linux |
| C#         | Windows               |
| Swift      | macOS, iOS            |
| Kotlin     | android               |
| TypeScript | web                   |

### Supported Features

- nim `proc`s and `func`s with the following primitives as arguments & return type:
  - int, bool, float, float32, char, string (including Unicode)
- nim enumerations, including flag enums/bit fields (single value supported, sets aren't supported yet)

### Usage

    genbondhon --jvmPkgName <jvmPackageName> <file>

`<jvmPackageName>`: Package name for Kotlin JNI binding. Omitting it will use a default package name, which is probably not what you want if you need the Kotlin binding.

`<file>`: The nim file to generate binding from.

Bindings will be generated for the exported symbols.
Each language folder inside binding directory has a `ReadMe.md` inside them,
containing instructions to build the nim library and to use it with the language
using the generated binding.

Full options can be found by using the `-h` or `--help` flag.

### Example

If you have the following nim file:

_hello.nim_

    type Direction* {.pure.} = enum
      north
      east
      south
      west

    func sayHello*(name: string): string =
      "Héllø " & name


And you run genbondhon on `hello.nim`,

    genbondhon hello.nim

\*_Using default `jvmPkgName` for demonstration purpose._

Then you will get the following language bindings in their respective directory within `./bindings`:

_hello.h_

    #ifndef HELLO_H
    #define HELLO_H

    typedef enum {
        NORTH,
        EAST,
        SOUTH,
        WEST
    } Direction;

    void NimMain();

    const char* sayHello(const char* name);

    #endif /* HELLO_H */


_hello.hpp_

    #ifndef HELLO_HPP
    #define HELLO_HPP

    extern "C" {
        enum class Direction {
            North,
            East,
            South,
            West
        };

        void NimMain();

        const char* sayHello(const char* name);
    }

    #endif /* HELLO_HPP */


_hello.cs_

    using System.Runtime.InteropServices;

    namespace HelloLib
    {
        public class Hello
        {
            public enum Direction: byte
            {
                North,
                East,
                South,
                West
            }

            [DllImport("hello.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Unicode, EntryPoint = "NimMain")]
            public static extern void NimMain();

            [return: MarshalAs(UnmanagedType.LPUTF8Str)]
            [DllImport("hello.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Unicode, EntryPoint = "sayHello")]
            public static extern string SayHello([MarshalAs(UnmanagedType.LPUTF8Str)] string name);
        }
    }


_hello.swift_

    import CHello

    enum Direction: CUnsignedInt {
        case north
        case east
        case south
        case west
    }

    func NimMain() {
        CHello.NimMain()
    }

    func sayHello(name: String) -> String {
        let temp = CHello.sayHello(name)
        guard let data = temp else {
            print("Error!! Failed to get string from sayHello")
            return "Failed to get string from sayHello"
        }
        return String(cString: data)
    }


_Hello.kt_

    package com.example.test

    class Hello {
        enum class Direction {
            NORTH,
            EAST,
            SOUTH,
            WEST
        }

        external fun nimMain()

        external fun sayHello(name: String): String

        companion object {
            init {
                System.loadLibrary("helloJNI")
            }
        }
    }


_hello.d.ts_

    export enum Direction {
      North,
      East,
      South,
      West,
    }

    export function sayHello(name: string): string;


### Development

#### Setup

This project requires atlas 0.9.0, which is shipped with nim 2.2.4. It is possible to use the updated atlas to install the dependencies, and use any other nim 2 version.

To setup the project, doing `atlas install genbondhon.nimble` should suffice.

#### Build & Run

This project uses nim tasks defined in config.nims for development.
Tasks can be called from command line from the root directory.

To create a release build, run

    nim build

To run debug build, use

    nim dev tests/nomuna.nim

Add flags after the filepath if needed, e.g.

    nim dev tests/nomuna.nim --verbose

#### Live Reload

You can use [monit](https://github.com/jiro4989/monit) for live reload. Install, and then use the following to build and run debug build with live reload.

    monit run

#### Debugging

Use `CodeLLDB` for debugging. Task & Debug configs exist in .vscode directory, taken from [official nim extension](https://github.com/nim-lang/vscode-nim?tab=readme-ov-file#debugging).

#### Format, Lint

To check formatting & linting, run

    nimcr check.nim

Or, on macOS & linux, you can just run `./check.nim`.

#### Tests

To run tests, use

    nim test

Tests may expect cli programs in path.

#### Cleanup

To cleanup generated files, use

    nim clean

### License

All files have corresponding licenses ensured by `reuse` tool. The binary is under MIT license.

### Acknowledgements

[genny](https://github.com/treeform/genny)
