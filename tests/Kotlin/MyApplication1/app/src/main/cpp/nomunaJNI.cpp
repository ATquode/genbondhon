// SPDX-FileCopyrightText: 2025 Rifat Hasan <atunutemp1@gmail.com>
//
// SPDX-License-Identifier: MIT

#include <jni.h>
#include "nomuna.hpp"

extern "C"
JNIEXPORT void JNICALL
Java_com_example_myapplication1_Nomuna_nimMain(JNIEnv *env, jobject thiz) {
    NimMain();
}

extern "C"
JNIEXPORT void JNICALL
Java_com_example_myapplication1_Nomuna_noop(JNIEnv *env, jobject thiz) {
    noop();
}

extern "C"
JNIEXPORT void JNICALL
Java_com_example_myapplication1_Nomuna_extraNoOp(JNIEnv *env, jobject thiz) {
    extraNoOp();
}

extern "C"
JNIEXPORT jint JNICALL
Java_com_example_myapplication1_Nomuna_constRet(JNIEnv *env, jobject thiz) {
    return (jint)constRet();
}

extern "C"
JNIEXPORT jboolean JNICALL
Java_com_example_myapplication1_Nomuna_constRetBool(JNIEnv *env, jobject thiz) {
    return (jboolean)constRetBool();
}

extern "C"
JNIEXPORT jdouble JNICALL
Java_com_example_myapplication1_Nomuna_constRetFloat(JNIEnv *env, jobject thiz) {
    return (jdouble)constRetFloat();
}

extern "C"
JNIEXPORT jchar JNICALL
Java_com_example_myapplication1_Nomuna_constRetChar(JNIEnv *env, jobject thiz) {
    return (jchar)constRetChar();
}

extern "C"
JNIEXPORT jstring JNICALL
Java_com_example_myapplication1_Nomuna_constRetStr(JNIEnv *env, jobject thiz) {
    return env->NewStringUTF(constRetStr());
}

extern "C"
JNIEXPORT jstring JNICALL
Java_com_example_myapplication1_Nomuna_constRetUnicodeStr(JNIEnv *env, jobject thiz) {
    return env->NewStringUTF(constRetUnicodeStr());
}

extern "C"
JNIEXPORT jint JNICALL
Java_com_example_myapplication1_Nomuna_addIntNum(JNIEnv *env, jobject thiz, jint a, jint b) {
    return (jint)addIntNum((int)a, (int)b);
}

extern "C"
JNIEXPORT void JNICALL
Java_com_example_myapplication1_Nomuna_printCond(JNIEnv *env, jobject thiz, jboolean a) {
    printCond((bool)a);
}

extern "C"
JNIEXPORT jdouble JNICALL
Java_com_example_myapplication1_Nomuna_addDouble(JNIEnv *env, jobject thiz, jdouble a, jdouble b) {
    return (jdouble)addDouble((double)a, (double)b);
}

extern "C"
JNIEXPORT jfloat JNICALL
Java_com_example_myapplication1_Nomuna_addFloat(JNIEnv *env, jobject thiz, jfloat a, jfloat b) {
    return (jfloat)addFloat((float)a, (float)b);
}

extern "C"
JNIEXPORT void JNICALL
Java_com_example_myapplication1_Nomuna_takeChar(JNIEnv *env, jobject thiz, jchar a) {
    takeChar((char)a);
}

extern "C"
JNIEXPORT void JNICALL
Java_com_example_myapplication1_Nomuna_printStr(JNIEnv *env, jobject thiz, jstring a) {
    const char* c_a = env->GetStringUTFChars(a, nullptr);
    printStr(c_a);
    env->ReleaseStringUTFChars(a, c_a);
}

extern "C"
JNIEXPORT jstring JNICALL
Java_com_example_myapplication1_Nomuna_sayHello(JNIEnv *env, jobject thiz, jstring name) {
    const char* c_name = env->GetStringUTFChars(name, nullptr);
    auto data = sayHello(c_name);
    env->ReleaseStringUTFChars(name, c_name);
    return env->NewStringUTF(data);
}

extern "C"
JNIEXPORT void JNICALL
Java_com_example_myapplication1_Nomuna_print2Str(JNIEnv *env, jobject thiz, jstring str1, jstring str2) {
    const char* c_str1 = env->GetStringUTFChars(str1, nullptr);
    const char* c_str2 = env->GetStringUTFChars(str2, nullptr);
    print2Str(c_str1, c_str2);
    env->ReleaseStringUTFChars(str1, c_str1);
    env->ReleaseStringUTFChars(str2, c_str2);
}

extern "C"
JNIEXPORT void JNICALL
Java_com_example_myapplication1_Nomuna_printDirectionRawValueVal(JNIEnv *env, jobject thiz, jint direction) {
    auto c_direction = static_cast<Direction>((int)direction);
    printDirectionRawValue(c_direction);
}

extern "C"
JNIEXPORT jint JNICALL
Java_com_example_myapplication1_Nomuna_getDirectionVal(JNIEnv *env, jobject thiz, jstring hint) {
    const char* c_hint = env->GetStringUTFChars(hint, nullptr);
    auto data = getDirection(c_hint);
    env->ReleaseStringUTFChars(hint, c_hint);
    return (jint)data;
}

extern "C"
JNIEXPORT jint JNICALL
Java_com_example_myapplication1_Nomuna_getOppositeVal(JNIEnv *env, jobject thiz, jint direction) {
    auto c_direction = static_cast<Direction>((int)direction);
    return (jint)getOpposite(c_direction);
}

extern "C"
JNIEXPORT jint JNICALL
Java_com_example_myapplication1_Nomuna_togglePauseVal(JNIEnv *env, jobject thiz, jint curState) {
    auto c_curState = static_cast<GameState>((int)curState);
    return (jint)togglePause(c_curState);
}

extern "C"
JNIEXPORT jint JNICALL
Java_com_example_myapplication1_Nomuna_authenticateVal(JNIEnv *env, jobject thiz, jstring username) {
    const char* c_username = env->GetStringUTFChars(username, nullptr);
    auto data = authenticate(c_username);
    env->ReleaseStringUTFChars(username, c_username);
    return (jint)data;
}

extern "C"
JNIEXPORT jint JNICALL
Java_com_example_myapplication1_Nomuna_setGameStateVal(JNIEnv *env, jobject thiz, jstring username, jint state) {
    auto c_state = static_cast<GameState>((int)state);
    const char* c_username = env->GetStringUTFChars(username, nullptr);
    auto data = setGameState(c_username, c_state);
    env->ReleaseStringUTFChars(username, c_username);
    return (jint)data;
}
