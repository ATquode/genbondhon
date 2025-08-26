// SPDX-FileCopyrightText: 2025 Rifat Hasan <atunutemp1@gmail.com>
//
// SPDX-License-Identifier: GPL-2.0-or-later

#include "directionmodel.h"

#include <magic_enum/magic_enum.hpp>

DirectionModel::DirectionModel(QObject *parent)
    : QAbstractListModel{parent}
{
    this->connect(this, &DirectionModel::directionChanged, this, &DirectionModel::onDirectionChanged);

    constexpr auto directionList = magic_enum::enum_values<Direction>();
    for (Direction dir : directionList) {
        textList << QString::fromLatin1(magic_enum::enum_name(dir));
    }

    QMetaEnum metaEnumRole = QMetaEnum::fromType<Roles>();
    roleMap.insert(Roles::TextRole, QByteArray(metaEnumRole.valueToKey(Roles::TextRole)));
    roleMap.insert(Roles::ValueRole, QByteArray(metaEnumRole.valueToKey(Roles::ValueRole)));
}

int DirectionModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return valList.count();
}

QVariant DirectionModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid()) {
        return QVariant();
    }

    switch (role) {
    case Roles::TextRole:
        return textList[index.row()];
        break;
    case Roles::ValueRole:
        return QVariant::fromValue(valList[index.row()]);
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> DirectionModel::roleNames() const
{
    return roleMap;
}

void DirectionModel::onDirectionChanged()
{
    QString oDir = getOppositeDirection();
    Q_EMIT oppositeChanged(oDir);
}

QByteArray DirectionModel::getTextRole()
{
    return roleMap.value(Roles::TextRole);
}

QByteArray DirectionModel::getValueRole()
{
    return roleMap.value(Roles::ValueRole);
}

QString DirectionModel::getOppositeDirection()
{
    Direction dir = static_cast<Direction>(direction);
    Direction opDir = getOpposite(dir);
    int index = valList.indexOf(opDir);
    return textList[index];
}

#include "moc_directionmodel.cpp"
