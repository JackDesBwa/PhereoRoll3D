QT += quick
CONFIG += c++11
DEFINES += QT_DEPRECATED_WARNINGS

SOURCES += main.cpp
RESOURCES += qml.qrc

qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /tmp/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target
