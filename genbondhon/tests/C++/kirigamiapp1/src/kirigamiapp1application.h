// SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <AbstractKirigamiApplication>
#include <QQmlEngine>

#include "datamanager.h"

using namespace Qt::StringLiterals;

class KirigamiApp1Application : public AbstractKirigamiApplication
{
    Q_OBJECT
    QML_ELEMENT

public:
    explicit KirigamiApp1Application(QObject *parent = nullptr);

Q_SIGNALS:
    void incrementCounter();

private:
    DataManager *dataManager;
    void setupActions() override;
};
