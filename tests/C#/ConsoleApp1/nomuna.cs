// SPDX-FileCopyrightText: 2025 Rifat Hasan <atunutemp1@gmail.com>
//
// SPDX-License-Identifier: MIT

using System.Runtime.InteropServices;

namespace NomunaLib
{
    public class Nomuna
    {
        public enum Direction: byte
        {
            North,
            East,
            South,
            West
        }

        public enum GameState: byte
        {
            Playing = 100,
            Pause,
            Game_over
        }

        public enum HttpStatusCode: ushort
        {
            Ok = 200,
            Created,
            No_content = 204,
            Moved_permanently = 301,
            Found,
            Not_modified = 304,
            Bad_request = 400,
            Unauthorized,
            Forbidden = 403,
            Not_found,
            Internal_server_error = 500,
            Bad_gateway = 502,
            Service_unavailable
        }

        [DllImport("nomuna.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Unicode, EntryPoint = "NimMain")]
        public static extern void NimMain();

        [DllImport("nomuna.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Unicode, EntryPoint = "noop")]
        public static extern void Noop();

        [DllImport("nomuna.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Unicode, EntryPoint = "extraNoOp")]
        public static extern void ExtraNoOp();

        [DllImport("nomuna.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Unicode, EntryPoint = "constRet")]
        public static extern int ConstRet();

        [return: MarshalAs(UnmanagedType.U1)]
        [DllImport("nomuna.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Unicode, EntryPoint = "constRetBool")]
        public static extern bool ConstRetBool();

        [DllImport("nomuna.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Unicode, EntryPoint = "constRetFloat")]
        public static extern double ConstRetFloat();

        [return: MarshalAs(UnmanagedType.U1)]
        [DllImport("nomuna.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Unicode, EntryPoint = "constRetChar")]
        public static extern char ConstRetChar();

        [return: MarshalAs(UnmanagedType.LPUTF8Str)]
        [DllImport("nomuna.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Unicode, EntryPoint = "constRetStr")]
        public static extern string ConstRetStr();

        [return: MarshalAs(UnmanagedType.LPUTF8Str)]
        [DllImport("nomuna.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Unicode, EntryPoint = "constRetUnicodeStr")]
        public static extern string ConstRetUnicodeStr();

        [DllImport("nomuna.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Unicode, EntryPoint = "addIntNum")]
        public static extern int AddIntNum(int a, int b);

        [DllImport("nomuna.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Unicode, EntryPoint = "printCond")]
        public static extern void PrintCond([MarshalAs(UnmanagedType.U1)] bool a);

        [DllImport("nomuna.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Unicode, EntryPoint = "addDouble")]
        public static extern double AddDouble(double a, double b);

        [DllImport("nomuna.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Unicode, EntryPoint = "addFloat")]
        public static extern float AddFloat(float a, float b);

        [DllImport("nomuna.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Unicode, EntryPoint = "takeChar")]
        public static extern void TakeChar(char a);

        [DllImport("nomuna.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Unicode, EntryPoint = "printStr")]
        public static extern void PrintStr([MarshalAs(UnmanagedType.LPUTF8Str)] string a);

        [return: MarshalAs(UnmanagedType.LPUTF8Str)]
        [DllImport("nomuna.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Unicode, EntryPoint = "sayHello")]
        public static extern string SayHello([MarshalAs(UnmanagedType.LPUTF8Str)] string name);

        [DllImport("nomuna.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Unicode, EntryPoint = "print2Str")]
        public static extern void Print2Str([MarshalAs(UnmanagedType.LPUTF8Str)] string str1, [MarshalAs(UnmanagedType.LPUTF8Str)] string str2);

        public static void PrintDirectionRawValue(Direction direction) {
            PrintDirectionRawValueVal((byte)direction);
        }

        [DllImport("nomuna.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Unicode, EntryPoint = "printDirectionRawValue")]
        private static extern void PrintDirectionRawValueVal(byte direction);

        public static Direction GetDirection(string hint) {
            var data = GetDirectionVal(hint);
            return (Direction)data;
        }

        [DllImport("nomuna.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Unicode, EntryPoint = "getDirection")]
        private static extern byte GetDirectionVal([MarshalAs(UnmanagedType.LPUTF8Str)] string hint);

        public static Direction GetOpposite(Direction direction) {
            var data = GetOppositeVal((byte)direction);
            return (Direction)data;
        }

        [DllImport("nomuna.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Unicode, EntryPoint = "getOpposite")]
        private static extern byte GetOppositeVal(byte direction);

        public static GameState TogglePause(GameState curState) {
            var data = TogglePauseVal((byte)curState);
            return (GameState)data;
        }

        [DllImport("nomuna.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Unicode, EntryPoint = "togglePause")]
        private static extern byte TogglePauseVal(byte curState);

        public static HttpStatusCode Authenticate(string username) {
            var data = AuthenticateVal(username);
            return (HttpStatusCode)data;
        }

        [DllImport("nomuna.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Unicode, EntryPoint = "authenticate")]
        private static extern ushort AuthenticateVal([MarshalAs(UnmanagedType.LPUTF8Str)] string username);

        public static HttpStatusCode SetGameState(string username, GameState state) {
            var data = SetGameStateVal(username, (byte)state);
            return (HttpStatusCode)data;
        }

        [DllImport("nomuna.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Unicode, EntryPoint = "setGameState")]
        private static extern ushort SetGameStateVal([MarshalAs(UnmanagedType.LPUTF8Str)] string username, byte state);
    }
}
