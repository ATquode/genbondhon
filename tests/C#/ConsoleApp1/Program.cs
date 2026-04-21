// SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
//
// SPDX-License-Identifier: MIT

// See https://aka.ms/new-console-template for more information
using NomunaLib;
using System.Text;

Console.OutputEncoding = Encoding.UTF8;
Nomuna.NimMain();
Nomuna.Noop();
Nomuna.ExtraNoOp();
int a = Nomuna.ConstRet();
Console.WriteLine(a);
bool b = Nomuna.ConstRetBool();
Console.WriteLine(b);
double c = Nomuna.ConstRetFloat();
Console.WriteLine(c);
char d = Nomuna.ConstRetChar();
Console.WriteLine(d);
string e = Nomuna.ConstRetStr();
Console.WriteLine(e);
string i = Nomuna.ConstRetUnicodeStr();
Console.WriteLine(i);
int f = Nomuna.AddIntNum(5, 3);
Console.WriteLine(f);
Nomuna.PrintCond(f == 8);
Nomuna.PrintCond(f == 9);
double g = Nomuna.AddDouble(5.03, 3.05);
Console.WriteLine(g);
float h = Nomuna.AddFloat(5.3f, 3.5f);
Console.WriteLine(h);
Nomuna.TakeChar('a');
Nomuna.PrintStr("nim");
Nomuna.PrintStr("hello ñíℳ");
string j = Nomuna.SayHello("ñíℳ");
Console.WriteLine(j);
Nomuna.Print2Str("Hello", "World!");
Nomuna.Direction direction = Nomuna.Direction.South;
Nomuna.PrintDirectionRawValue(direction);
direction = Nomuna.GetOpposite(Nomuna.Direction.North);
Console.WriteLine($"Opposite of North: expected {Nomuna.Direction.South}, got {direction}");
direction = Nomuna.GetDirection("south");
Console.WriteLine($"Direction: {direction}, value: {(int)direction}");
Nomuna.GameState gameState = Nomuna.GameState.Game_over;
Console.WriteLine($"Game State: {gameState}, value: {(int)gameState}");
Nomuna.GameState newGameStete = Nomuna.TogglePause(gameState);
Console.WriteLine($"Game State: {newGameStete}, value: {(int)newGameStete}");
Nomuna.HttpStatusCode statusCode = Nomuna.Authenticate("user1");
Console.WriteLine($"Status code: {statusCode}, value: {(int)statusCode}");
statusCode = Nomuna.SetGameState("user", Nomuna.GameState.Game_over);
Console.WriteLine($"set Game State result: {statusCode}, value: {(int)statusCode}");
string newUser = Nomuna.RequestPermission(Nomuna.FilePermission.Write);
Console.WriteLine($"{newUser} has permission: {Nomuna.FilePermission.Write}, value: 0x{(int)Nomuna.FilePermission.Write:x2}");
Nomuna.FilePermission permission = Nomuna.GetLeastPriviledgedPermission();
Console.WriteLine($"Least priviledged permission: {permission}, value: 0x{(int)permission:x2}");
bool reqRes = Nomuna.RequestAccess(Nomuna.FilePermission.Write, "/");
Console.WriteLine($"Request access result: {reqRes}");
int k = Nomuna.AddIntNum2(11, 14);
Console.WriteLine(k);
(int l, int m) = Nomuna.DivMod(10, 3);
Console.WriteLine($"{l}, {m}");
var position = (1, 2);
var position3d = Nomuna.ExtendTo3D(position, 3);
Console.WriteLine($"{position3d.Item1}, {position3d.Item2}, {position3d.Item3}");
var newPosition3d = Nomuna.Translate3D((1, 2, 3), -2);
Console.WriteLine($"{newPosition3d.Item1}, {newPosition3d.Item2}, {newPosition3d.Item3}");
