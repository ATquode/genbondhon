// SPDX-License-Identifier: GPL-2.0-or-later
// SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>

#include "kirigamiapp1application.h"

#include <KAuthorized>
#include <KLocalizedString>

using namespace Qt::StringLiterals;

KirigamiApp1Application::KirigamiApp1Application(QObject *parent)
    : AbstractKirigamiApplication(parent)
{
    dataManager = DataManager::getSingleton();
    KirigamiApp1Application::setupActions();
}

void KirigamiApp1Application::setupActions()
{
    AbstractKirigamiApplication::setupActions();

    auto actionName = "increment_counter"_L1;
    if (KAuthorized::authorizeAction(actionName)) {
        auto action = mainCollection()->addAction(actionName, this, &KirigamiApp1Application::incrementCounter);
        action->setText(i18nc("@action:inmenu", "Increment"));
        action->setIcon(QIcon::fromTheme(u"list-add-symbolic"_s));
        mainCollection()->addAction(action->objectName(), action);
        mainCollection()->setDefaultShortcut(action, Qt::CTRL | Qt::Key_I);
    }

    readSettings();
}

#include "moc_kirigamiapp1application.cpp"
