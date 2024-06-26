// See https://aka.ms/new-console-template for more information
using NomunaLib;
using System.Text;

Console.OutputEncoding = Encoding.UTF8;
Console.WriteLine("Hello, World!");
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
