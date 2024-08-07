// SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
//
// SPDX-License-Identifier: MIT

using Microsoft.Windows.ApplicationModel.Resources;

namespace App1.Helpers;

public static class ResourceExtensions
{
    private static readonly ResourceLoader _resourceLoader = new();

    public static string GetLocalized(this string resourceKey) =>
        _resourceLoader.GetString(resourceKey);
}
