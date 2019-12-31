QT += quick
CONFIG += c++11
DEFINES += QT_DEPRECATED_WARNINGS

HEADERS += \
    src/httpcache.h \
    src/photolist.h \
    src/toolbox.h

SOURCES += \
    src/main.cpp \
    src/httpcache.cpp \
    src/photolist.cpp \
    src/toolbox.cpp

RESOURCES += resources.qrc

qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /tmp/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

DISTFILES += \
    android/AndroidManifest.xml \
    android/res/values/libs.xml \
    android/build.gradle \
    android/src/org/desbwa/phereoroll3d/PhereoRoll3DActivity.java

contains(ANDROID_TARGET_ARCH,armeabi-v7a) {
    ANDROID_PACKAGE_SOURCE_DIR = \
        $$PWD/android

    ANDROID_EXTRA_LIBS = \
        $$PWD/android/lib/libcrypto.so \
        $$PWD/android/lib/libssl.so
}
