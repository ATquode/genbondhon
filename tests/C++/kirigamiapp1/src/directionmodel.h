/*
 * SPDX-FileCopyrightText: 2025 Rifat Hasan <atunutemp1@gmail.com>
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#ifndef DIRECTIONMODEL_H
#define DIRECTIONMODEL_H

#include "nomuna.hpp"

#include <QAbstractListModel>
#include <QObject>
#include <QQmlEngine>

class DirectionModel : public QAbstractListModel
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(QByteArray textRole READ getTextRole CONSTANT)
    Q_PROPERTY(QByteArray valueRole READ getValueRole CONSTANT)
    Q_PROPERTY(int selectedDirection MEMBER direction NOTIFY directionChanged FINAL)
    Q_PROPERTY(QString oppositeDirection READ getOppositeDirection NOTIFY oppositeChanged FINAL)
public:
    enum Roles {
        TextRole = Qt::UserRole + 1,
        ValueRole
    };
    Q_ENUM(Roles)

    explicit DirectionModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

Q_SIGNALS:
    void directionChanged();
    void oppositeChanged(QString oDir);
public Q_SLOTS:
    void onDirectionChanged();

private:
    int direction;
    QStringList textList;
    QList<Direction> valList = {Direction::North, Direction::East, Direction::South, Direction::West};
    QHash<int, QByteArray> roleMap;

    QByteArray getTextRole();
    QByteArray getValueRole();
    QString getOppositeDirection();
};

#endif // DIRECTIONMODEL_H
