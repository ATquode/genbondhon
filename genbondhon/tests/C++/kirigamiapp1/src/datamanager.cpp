// SPDX-FileCopyrightText: 2024 Rifat Hasan <atunutemp1@gmail.com>
//
// SPDX-License-Identifier: GPL-2.0-or-later

#include "datamanager.h"
#include "nomuna.hpp"

DataManager::DataManager(QObject *parent)
    : QObject(parent)
{
    this->connect(this, &DataManager::addInt1Changed, this, &DataManager::onAddIntChanged);
    this->connect(this, &DataManager::addInt2Changed, this, &DataManager::onAddIntChanged);
    this->connect(this, &DataManager::addDouble1Changed, this, &DataManager::onAddDoubleChanged);
    this->connect(this, &DataManager::addDouble2Changed, this, &DataManager::onAddDoubleChanged);
    this->connect(this, &DataManager::addFloat1Changed, this, &DataManager::onAddFloatChanged);
    this->connect(this, &DataManager::addFloat2Changed, this, &DataManager::onAddFloatChanged);
    this->connect(this, &DataManager::sayHelloInputChanged, this, &DataManager::onSayHelloChanged);
    NimMain();
    noop();
    extraNoOp();
    printCond(intNumRes == 0);
    printCond(intNumRes != 0);
    takeChar('a');
}

DataManager *DataManager::getSingleton()
{
    if (!s_singletonInstance) {
        s_singletonInstance = new DataManager();
    }
    return s_singletonInstance;
}

DataManager *DataManager::create(QQmlEngine *, QJSEngine *engine)
{
    // The instance has to exist before it is used. We cannot replace it.
    Q_ASSERT(s_singletonInstance);

    // The engine has to have the same thread affinity as the singleton.
    Q_ASSERT(engine->thread() == s_singletonInstance->thread());

    // There can only be one engine accessing the singleton.
    if (s_engine)
        Q_ASSERT(engine == s_engine);
    else
        s_engine = engine;

    // Explicitly specify C++ ownership so that the engine doesn't delete
    // the instance.
    QJSEngine::setObjectOwnership(s_singletonInstance, QJSEngine::CppOwnership);
    return s_singletonInstance;
}

void DataManager::onAddIntChanged()
{
    intNumRes = addInt(intNum1, intNum2);
    Q_EMIT addIntResChanged(intNumRes);
}

void DataManager::onAddDoubleChanged()
{
    doubleNumRes = addDouble(doubleNum1, doubleNum2);
    Q_EMIT addDoubleResChanged(doubleNumRes);
}

void DataManager::onAddFloatChanged()
{
    floatNumRes = addFloat(floatNum1, floatNum2);
    Q_EMIT addFloatResChanged(floatNumRes);
}

void DataManager::onSayHelloChanged()
{
    const char *greeting = sayHello(inputStr.toUtf8().constData());
    sayHelloOutput = QString::fromUtf8(greeting);
    Q_EMIT sayHelloOutputChanged(sayHelloOutput);
}

int DataManager::getIntRetVal()
{
    return constRet();
}

bool DataManager::getBoolRetVal()
{
    return constRetBool();
}

double DataManager::getDoubleRetVal()
{
    return constRetFloat();
}

QString DataManager::getCharRetVal()
{
    char ch = constRetChar();
    std::string s{ch};
    return QString::fromStdString(s);
}

QString DataManager::getStrRetVal()
{
    const char *str = constRetStr();
    return QString::fromUtf8(str);
}

QString DataManager::getUnicodeStrRetVal()
{
    const char *str = constRetUnicodeStr();
    return QString::fromUtf8(str);
}

int DataManager::getAddIntRes()
{
    return intNumRes;
}

double DataManager::getAddDoubleRes()
{
    return doubleNumRes;
}

float DataManager::getAddFloatRes()
{
    return floatNumRes;
}

QString DataManager::getSayHelloOutput()
{
    return sayHelloOutput;
}

#include "moc_datamanager.cpp"
