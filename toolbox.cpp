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
    regexpURL = QRegularExpression("(https?://([^\\s])+)");
    regexpURL.optimize();
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

QString Toolbox::reformatText(QString txt) {
    txt.replace(regexpURL, "<a href=\"\\1\" style=\"color: white;\">\\1</a>");
    return txt;
}
