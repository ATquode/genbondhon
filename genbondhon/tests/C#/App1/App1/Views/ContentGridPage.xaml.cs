// SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
//
// SPDX-License-Identifier: MIT

using App1.ViewModels;
using Microsoft.UI.Xaml.Controls;

namespace App1.Views;

public sealed partial class ContentGridPage : Page
{
    public ContentGridViewModel ViewModel { get; }

    public ContentGridPage()
    {
        ViewModel = App.GetService<ContentGridViewModel>();
        InitializeComponent();
    }
}
