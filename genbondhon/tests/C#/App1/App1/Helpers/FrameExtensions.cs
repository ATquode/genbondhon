// SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
//
// SPDX-License-Identifier: MIT

using Microsoft.UI.Xaml.Controls;

namespace App1.Helpers;

public static class FrameExtensions
{
    public static object? GetPageViewModel(this Frame frame) =>
        frame?.Content?.GetType().GetProperty("ViewModel")?.GetValue(frame.Content, null);
}
