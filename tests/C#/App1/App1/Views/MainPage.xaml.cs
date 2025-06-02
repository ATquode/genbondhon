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
        Nomuna.Noop();
        Nomuna.ExtraNoOp();
    }
}
