#include "toolbox.h"

#include <QFile>
#include <QDir>
#include <QStandardPaths>
#include <QFileInfo>
#include <QCryptographicHash>

namespace {
QString picturesPath = QStandardPaths::writableLocation(QStandardPaths::PicturesLocation);
QString picturesPathFinal = picturesPath + QDir::separator() + "PhereoRoll3D";
}

Toolbox::Toolbox(QObject *parent) : QObject(parent) {
}

bool Toolbox::hasWritePermissions() {
    QString testPath = picturesPathFinal;
    if (!QFile(testPath).exists())
        testPath = picturesPath;
    QFileInfo picturesPathInfo(testPath);
    return (picturesPathInfo.isDir() && picturesPathInfo.isWritable());
}

QString Toolbox::md5(QString txt) {
    return QCryptographicHash::hash(txt.toUtf8(), QCryptographicHash::Md5).toHex();
}
