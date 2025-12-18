// SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
//
// SPDX-License-Identifier: MIT

using System.Collections.ObjectModel;
using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using NomunaLib;
using Windows.Globalization.NumberFormatting;

namespace App1.ViewModels;

public partial class MainViewModel : ObservableRecipient
{
    [ObservableProperty]
    private int intRetVal;

    [ObservableProperty]
    private bool boolRetVal;

    [ObservableProperty]
    private double doubleRetVal;

    [ObservableProperty]
    private char charRetVal;

    [ObservableProperty]
    private string stringRetVal;

    [ObservableProperty]
    private string unicodeStringRetVal;

    [ObservableProperty]
    private string addInt1;

    [ObservableProperty]
    private string addInt2;

    [ObservableProperty]
    private string addIntRes;

    [ObservableProperty]
    private string addDouble1;

    [ObservableProperty]
    private string addDouble2;

    [ObservableProperty]
    private string addDoubleRes;

    [ObservableProperty]
    private string addFloat1;

    [ObservableProperty]
    private string addFloat2;

    [ObservableProperty]
    private string addFloatRes;

    [ObservableProperty]
    private string sayHelloInput;

    [ObservableProperty]
    private string sayHelloOutput;

    [ObservableProperty]
    private ObservableCollection<Nomuna.Direction> directions = new(
        Enum.GetValues<Nomuna.Direction>()
    );

    [ObservableProperty]
    private Nomuna.Direction selectedDirection;

    public string OppositeDirection
    {
        get
        {
            var oppositeDir = Nomuna.GetOpposite(selectedDirection);
            return oppositeDir.ToString();
        }
    }

    private readonly Lazy<DecimalFormatter> _intFormatter =
        new(() =>
        {
            var formatter = new DecimalFormatter { FractionDigits = 0 };
            var rounder = new IncrementNumberRounder
            {
                RoundingAlgorithm = RoundingAlgorithm.RoundDown
            };
            formatter.NumberRounder = rounder;
            return formatter;
        });
    public DecimalFormatter IntFormatter => _intFormatter.Value;

    private readonly Lazy<DecimalFormatter> _doubleFormatter =
        new(() =>
        {
            var formatter = new DecimalFormatter { FractionDigits = 4 };
            var rounder = new IncrementNumberRounder { Increment = 0.0001 };
            formatter.NumberRounder = rounder;
            return formatter;
        });
    public DecimalFormatter DoubleFormatter => _doubleFormatter.Value;

    private readonly Lazy<DecimalFormatter> _floatFormatter =
        new(() =>
        {
            var formatter = new DecimalFormatter { FractionDigits = 2 };
            var rounder = new IncrementNumberRounder { Increment = 0.01 };
            formatter.NumberRounder = rounder;
            return formatter;
        });
    public DecimalFormatter FloatFormatter => _floatFormatter.Value;

    public MainViewModel()
    {
        intRetVal = Nomuna.ConstRet();
        boolRetVal = Nomuna.ConstRetBool();
        doubleRetVal = Nomuna.ConstRetFloat();
        charRetVal = Nomuna.ConstRetChar();
        stringRetVal = Nomuna.ConstRetStr();
        unicodeStringRetVal = Nomuna.ConstRetUnicodeStr();
        addInt1 =
            addInt2 =
            addDouble1 =
            addDouble2 =
            addFloat1 =
            addFloat2 =
            sayHelloInput =
            sayHelloOutput =
                "";
        addIntRes = addDoubleRes = addFloatRes = "0";
        selectedDirection = Nomuna.Direction.North;
        Nomuna.PrintCond(addIntRes == "0");
        Nomuna.PrintCond(addIntRes != "0");
        Nomuna.TakeChar('a');
        Nomuna.PrintStr("nim");
        Nomuna.PrintStr("hello ñíℳ");
        Nomuna.Print2Str("Hello", "World!");
        Nomuna.Direction direction = Nomuna.Direction.South;
        Nomuna.PrintDirectionRawValue(direction);
        direction = Nomuna.GetDirection("south");
        Console.WriteLine($"Direction: {direction}, value: {(int)direction}");
        Nomuna.GameState gameState = Nomuna.GameState.Game_over;
        Console.WriteLine($"Game State: {gameState}, value: {((int)gameState)}");
        Nomuna.GameState newGameState = Nomuna.TogglePause(gameState);
        Console.WriteLine($"Game State: {newGameState}, value: {((int)newGameState)}");
        Nomuna.HttpStatusCode statusCode = Nomuna.Authenticate("user1");
        Console.WriteLine($"Status code: {statusCode}, value: {(int)statusCode}");
        statusCode = Nomuna.SetGameState("user", Nomuna.GameState.Game_over);
        Console.WriteLine($"set Game State result: {statusCode}, value: {(int)statusCode}");
        string newUser = Nomuna.RequestPermission(Nomuna.FilePermission.Write);
        Console.WriteLine(
            $"{newUser} has permission: {Nomuna.FilePermission.Write}, value: 0x{(int)Nomuna.FilePermission.Write:x2}"
        );
        Nomuna.FilePermission permission = Nomuna.GetLeastPriviledgedPermission();
        Console.WriteLine($"Least priviledged permission: {permission}, value: {(int)permission}");
    }

    [RelayCommand]
    private void PerformAddInt()
    {
        int i;
        var num1 = int.TryParse(AddInt1, out i) ? i : 0;
        var num2 = int.TryParse(AddInt2, out i) ? i : 0;
        var sum = Nomuna.AddIntNum(num1, num2);
        AddIntRes = sum.ToString();
    }

    [RelayCommand]
    private void PerformAddDouble()
    {
        double d;
        var num1 = double.TryParse(AddDouble1, out d) ? d : 0;
        var num2 = double.TryParse(AddDouble2, out d) ? d : 0;
        var sum = Nomuna.AddDouble(num1, num2);
        sum = Math.Round(sum, 4);
        AddDoubleRes = sum.ToString();
    }

    [RelayCommand]
    private void PerformAddFloat()
    {
        float f;
        var num1 = float.TryParse(AddFloat1, out f) ? f : 0;
        var num2 = float.TryParse(AddFloat2, out f) ? f : 0;
        var sum = Nomuna.AddFloat(num1, num2);
        AddFloatRes = sum.ToString();
    }

    [RelayCommand]
    private void PerformSayHello()
    {
        SayHelloOutput = Nomuna.SayHello(SayHelloInput);
    }

    partial void OnSelectedDirectionChanged(Nomuna.Direction value)
    {
        OnPropertyChanged(nameof(OppositeDirection));
    }
}
