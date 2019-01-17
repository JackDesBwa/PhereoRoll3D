#include "toolbox.h"

#include <QFile>
#include <QDir>
#include <QStandardPaths>
#include <QFileInfo>
#include <QCryptographicHash>
#include <QNetworkRequest>
#include <QNetworkReply>

namespace {
Toolbox * toolboxInstance = nullptr;
QString initUri;
QString picturesPath = QStandardPaths::writableLocation(QStandardPaths::PicturesLocation);
QString picturesPathFinal = picturesPath + QDir::separator() + "PhereoRoll3D";
}

Toolbox::Toolbox(QNetworkAccessManager & nam, QObject *parent) : QObject(parent), m_nam(nam) {
    regexpURL = QRegularExpression("(https?://([^\\s])+)");
    regexpURL.optimize();
    toolboxInstance = this;
    if (!initUri.isNull())
        setUri(QString(initUri));
}

void Toolbox::setUri(QString uri) {
    m_lastUri = uri;
    uriReceived(m_lastUri);
}

QString Toolbox::lastUri() {
    return m_lastUri;
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
    txt.replace("\n", "<br>");
    return txt;
}

void Toolbox::download(QString imgurl, QString imgid) {
    QNetworkRequest request;
    request.setUrl(QUrl(imgurl));

    QNetworkReply *reply = m_nam.get(request);
    QObject::connect(reply, &QNetworkReply::readyRead, this, [this, reply, imgid](){
        QDir().mkpath(picturesPathFinal);
        QFile f(picturesPathFinal + QDir::separator() + imgid + "_3d_sbs.jpg");
        if (f.open(QFile::WriteOnly)) {
            f.write(reply->readAll());
            m_imgPath = f.fileName();
            emit imgPathChanged();
            emit downloadEnd(true, f.fileName());
        } else {
            emit downloadEnd(false);
        }
        reply->deleteLater();
    });
    auto error = [this, reply](){
        emit downloadEnd(false);
        reply->deleteLater();
    };
    QObject::connect(reply, static_cast<void(QNetworkReply::*)(QNetworkReply::NetworkError)>(&QNetworkReply::error), this, error);
    QObject::connect(reply, &QNetworkReply::sslErrors, this, error);
}

void Toolbox::setDownloadId(QString imgid) {
    QFile f(picturesPathFinal + QDir::separator() + imgid + "_3d_sbs.jpg");
    m_imgPath = f.exists() ? f.fileName() : "";
    emit imgPathChanged();
}

#ifdef Q_OS_ANDROID
#include <jni.h>
extern "C" JNIEXPORT void JNICALL Java_org_desbwa_phereoroll3d_PhereoRoll3DActivity_openedUri(JNIEnv *env, jobject /*obj*/, jstring url) {
    const char *urlStr = env->GetStringUTFChars(url, nullptr);
    if (toolboxInstance) {
        toolboxInstance->setUri(QString(urlStr));
    } else {
        initUri = QString(urlStr);
    }
    env->ReleaseStringUTFChars(url, urlStr);
}
#endif
