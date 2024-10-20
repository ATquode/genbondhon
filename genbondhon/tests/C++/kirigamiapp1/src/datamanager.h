/*
 * SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#ifndef DATAMANAGER_H
#define DATAMANAGER_H

#include <QQmlEngine>

using namespace Qt::Literals::StringLiterals;

class DataManager : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(int intRetVal READ getIntRetVal CONSTANT)
    Q_PROPERTY(bool boolRetVal READ getBoolRetVal CONSTANT)
    Q_PROPERTY(double doubleRetVal READ getDoubleRetVal CONSTANT)
    Q_PROPERTY(QString charRetVal READ getCharRetVal CONSTANT)
    Q_PROPERTY(QString strRetVal READ getStrRetVal CONSTANT)
    Q_PROPERTY(QString unicodeStrRetVal READ getUnicodeStrRetVal CONSTANT)

    Q_PROPERTY(int addInt1 MEMBER intNum1 NOTIFY addInt1Changed FINAL)
    Q_PROPERTY(int addInt2 MEMBER intNum2 NOTIFY addInt2Changed FINAL)
    Q_PROPERTY(int addIntRes READ getAddIntRes NOTIFY addIntResChanged FINAL)
    Q_PROPERTY(double addDouble1 MEMBER doubleNum1 NOTIFY addDouble1Changed FINAL)
    Q_PROPERTY(double addDouble2 MEMBER doubleNum2 NOTIFY addDouble2Changed FINAL)
    Q_PROPERTY(double addDoubleRes READ getAddDoubleRes NOTIFY addDoubleResChanged FINAL)
    Q_PROPERTY(float addFloat1 MEMBER floatNum1 NOTIFY addFloat1Changed FINAL)
    Q_PROPERTY(float addFloat2 MEMBER floatNum2 NOTIFY addFloat2Changed FINAL)
    Q_PROPERTY(float addFloatRes READ getAddFloatRes NOTIFY addFloatResChanged FINAL)
    Q_PROPERTY(QString sayHelloInput MEMBER inputStr NOTIFY sayHelloInputChanged FINAL)
    Q_PROPERTY(QString sayHelloOutput READ getSayHelloOutput NOTIFY sayHelloOutputChanged FINAL)
public:
    static DataManager *getSingleton();
    static DataManager *create(QQmlEngine *, QJSEngine *engine);

Q_SIGNALS:
    void addInt1Changed();
    void addInt2Changed();
    void addIntResChanged(int newVal);
    void addDouble1Changed();
    void addDouble2Changed();
    void addDoubleResChanged(double newVal);
    void addFloat1Changed();
    void addFloat2Changed();
    void addFloatResChanged(float newVal);
    void sayHelloInputChanged();
    void sayHelloOutputChanged(QString newVal);

public Q_SLOTS:
    void onAddIntChanged();
    void onAddDoubleChanged();
    void onAddFloatChanged();
    void onSayHelloChanged();

private:
    inline static DataManager *s_singletonInstance = nullptr;
    inline static QJSEngine *s_engine = nullptr;
    int intNum1 = 0, intNum2 = 0, intNumRes = 0;
    double doubleNum1 = 0, doubleNum2 = 0, doubleNumRes = 0;
    float floatNum1 = 0, floatNum2 = 0, floatNumRes = 0;
    QString inputStr = u""_s, sayHelloOutput = u""_s;

    explicit DataManager(QObject *parent = nullptr);
    int getIntRetVal();
    bool getBoolRetVal();
    double getDoubleRetVal();
    QString getCharRetVal();
    QString getStrRetVal();
    QString getUnicodeStrRetVal();

    int getAddIntRes();
    double getAddDoubleRes();
    float getAddFloatRes();
    QString getSayHelloOutput();
};

#endif // DATAMANAGER_H
