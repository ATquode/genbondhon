// SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
//
// SPDX-License-Identifier: MIT

using App1.ViewModels;
using Microsoft.UI.Xaml.Controls;
using NomunaLib;
using Windows.Globalization.NumberFormatting;

namespace App1.Views;

public sealed partial class MainPage : Page
{
    public MainViewModel ViewModel { get; }

    public MainPage()
    {
        ViewModel = App.GetService<MainViewModel>();
        InitializeComponent();
        SetNumberBoxNumberFormatter();
        Nomuna.Noop();
        Nomuna.ExtraNoOp();
    }

    private void SetNumberBoxNumberFormatter()
    {
        var formatter = new DecimalFormatter { FractionDigits = 0 };
        var rounder = new IncrementNumberRounder
        {
            RoundingAlgorithm = RoundingAlgorithm.RoundDown
        };
        formatter.NumberRounder = rounder;
        AddNumInt1.NumberFormatter = formatter;
        AddNumInt2.NumberFormatter = formatter;

        var formatter1 = new DecimalFormatter { FractionDigits = 4 };
        var rounder1 = new IncrementNumberRounder { Increment = 0.0001 };
        formatter1.NumberRounder = rounder1;
        AddNumDouble1.NumberFormatter = formatter1;
        AddNumDouble2.NumberFormatter = formatter1;

        var formatter2 = new DecimalFormatter { FractionDigits = 2 };
        var rounder2 = new IncrementNumberRounder { Increment = 0.01 };
        formatter2.NumberRounder = rounder2;
        AddNumFloat1.NumberFormatter = formatter2;
        AddNumFloat2.NumberFormatter = formatter2;
    }
}
