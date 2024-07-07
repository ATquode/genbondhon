// SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
//
// SPDX-License-Identifier: MIT

namespace App1.Contracts.Services;

public interface IActivationService
{
    Task ActivateAsync(object activationArgs);
}
