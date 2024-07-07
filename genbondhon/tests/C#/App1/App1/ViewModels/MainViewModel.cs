// SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
//
// SPDX-License-Identifier: MIT

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

    public MainViewModel()
    {
        intRetVal = Nomuna.ConstRet();
        boolRetVal = Nomuna.ConstRetBool();
        doubleRetVal = Nomuna.ConstRetFloat();
        charRetVal = Nomuna.ConstRetChar();
        stringRetVal = Nomuna.ConstRetStr();
        addInt1 = addInt2 = addDouble1 = addDouble2 = addFloat1 = addFloat2 = "";
        addIntRes = addDoubleRes = addFloatRes = "0";
        Nomuna.PrintCond(addIntRes == "0");
        Nomuna.PrintCond(addIntRes != "0");
        Nomuna.TakeChar('a');
        Nomuna.PrintStr("nim");
        Nomuna.PrintStr("hello ñíℳ");
    }

    [RelayCommand]
    private void PerformAddInt()
    {
        int i;
        var num1 = int.TryParse(AddInt1, out i) ? i : 0;
        var num2 = int.TryParse(AddInt2, out i) ? i : 0;
        var sum = Nomuna.AddInt(num1, num2);
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
}
