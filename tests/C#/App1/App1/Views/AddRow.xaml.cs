// SPDX-FileCopyrightText: 2025 Rifat Hasan <atunutemp1@gmail.com>
//
// SPDX-License-Identifier: MIT

using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices.WindowsRuntime;
using CommunityToolkit.Mvvm.Input;
using Microsoft.UI.Xaml;
using Microsoft.UI.Xaml.Controls;
using Microsoft.UI.Xaml.Controls.Primitives;
using Microsoft.UI.Xaml.Data;
using Microsoft.UI.Xaml.Input;
using Microsoft.UI.Xaml.Media;
using Microsoft.UI.Xaml.Navigation;
using Windows.Foundation;
using Windows.Foundation.Collections;
using Windows.Globalization.NumberFormatting;

// To learn more about WinUI, the WinUI project structure,
// and more about our project templates, see: http://aka.ms/winui-project-info.

namespace App1.Views;

public sealed partial class AddRow : UserControl
{
    public string? Title
    {
        get => GetValue(TitleProperty) as string;
        set => SetValue(TitleProperty, value);
    }
    public static readonly DependencyProperty TitleProperty = DependencyProperty.Register(
        nameof(Title),
        typeof(string),
        typeof(AddRow),
        new PropertyMetadata(null)
    );

    public string? AddNum1
    {
        get => GetValue(AddNum1Property) as string;
        set => SetValue(AddNum1Property, value);
    }
    public static readonly DependencyProperty AddNum1Property = DependencyProperty.Register(
        nameof(AddNum1),
        typeof(string),
        typeof(AddRow),
        new PropertyMetadata(null)
    );

    public string? AddNum2
    {
        get => GetValue(AddNum2Property) as string;
        set => SetValue(AddNum2Property, value);
    }
    public static readonly DependencyProperty AddNum2Property = DependencyProperty.Register(
        nameof(AddNum2),
        typeof(string),
        typeof(AddRow),
        new PropertyMetadata(null)
    );

    public string? AddNumRes
    {
        get => GetValue(AddNumResProperty) as string;
        set => SetValue(AddNumResProperty, value);
    }
    public static readonly DependencyProperty AddNumResProperty = DependencyProperty.Register(
        nameof(AddNumRes),
        typeof(string),
        typeof(AddRow),
        new PropertyMetadata(null)
    );

    public IRelayCommand? PerformAddCommand
    {
        get => GetValue(PerformAddCommandProperty) as IRelayCommand;
        set => SetValue(PerformAddCommandProperty, value);
    }
    public static readonly DependencyProperty PerformAddCommandProperty =
        DependencyProperty.Register(
            nameof(PerformAddCommand),
            typeof(IRelayCommand),
            typeof(AddRow),
            new PropertyMetadata(null)
        );

    public DecimalFormatter? Formatter
    {
        get => GetValue(FormatterProperty) as DecimalFormatter;
        set => SetValue(FormatterProperty, value);
    }
    public static readonly DependencyProperty FormatterProperty = DependencyProperty.Register(
        nameof(Formatter),
        typeof(DecimalFormatter),
        typeof(AddRow),
        new PropertyMetadata(null, OnFormatterPropertyChanged)
    );

    public AddRow()
    {
        InitializeComponent();
    }

    private void SetNumberBoxNumberFormatter()
    {
        if (Formatter == null)
        {
            Debug.WriteLine("Formatter is null");
            return;
        }
        AddNum1Box.NumberFormatter = Formatter;
        AddNum2Box.NumberFormatter = Formatter;
    }

    private static void OnFormatterPropertyChanged(
        DependencyObject d,
        DependencyPropertyChangedEventArgs e
    )
    {
        if (d is AddRow control)
        {
            control.SetNumberBoxNumberFormatter();
        }
    }
}
