#include "httpcache.h"

#include <QNetworkDiskCache>
#include <QNetworkReply>
#include <QStandardPaths>
#include <QCoreApplication>

namespace {
class NetworkErrorReply : public QNetworkReply {
public:
    NetworkErrorReply(QNetworkReply::NetworkError error, QString reason) {
        setError(error, reason);
        setFinished(true);
        QMetaObject::invokeMethod(this, "error", Qt::QueuedConnection,
                                  Q_ARG(QNetworkReply::NetworkError, error));
        QMetaObject::invokeMethod(this, "finished", Qt::QueuedConnection);
    }
    void abort() override {}
    qint64 readData(char *, qint64) override { return 0; }
};
}

QByteArray HttpCache_NAM::userAgent() {
    if (m_userAgent.isEmpty()) {
        QString osDetails;
#if defined(Q_OS_ANDROID)
        osDetails = QString("Linux; Android %1; %2").arg(QSysInfo::currentCpuArchitecture(), QSysInfo::prettyProductName());
#elif defined(Q_OS_LINUX)
        osDetails = QString("X11; Linux %1").arg(QSysInfo::currentCpuArchitecture());
#elif defined(Q_OS_MAC)
        osDetails = QString("Macintosh; Mac OS X %1").arg(QSysInfo::productVersion());
#elif defined(Q_OS_WIN)
        osDetails = QString("Windows NT %1").arg(QSysInfo::kernelVersion());
#endif
        m_userAgent = QString("Mozilla/5.0 (%1) %2/%3").arg(osDetails, qApp->applicationName(), qApp->applicationVersion()).toLatin1();
    }
    return m_userAgent;
}

QNetworkReply * HttpCache_NAM::createRequest(QNetworkAccessManager::Operation op, const QNetworkRequest &originalReq, QIODevice *outgoingData) {
    if (originalReq.url().url() == "https://api.phereo.com/files/avatar.jpg")
        return new NetworkErrorReply(QNetworkReply::ContentNotFoundError, "User has not defined its avatar");

    auto req = originalReq;
    req.setAttribute(QNetworkRequest::CacheLoadControlAttribute, QNetworkRequest::PreferCache);
    req.setAttribute(QNetworkRequest::CacheSaveControlAttribute, true);
    req.setAttribute(QNetworkRequest::HttpPipeliningAllowedAttribute, true);
    if (!req.hasRawHeader("User-Agent"))
        req.setRawHeader("User-Agent", userAgent());

    QNetworkReply * rep = QNetworkAccessManager::createRequest(op, req, outgoingData);

    return rep;
}

QNetworkAccessManager * HttpCache_NAMF::create(QObject *parent) {
    auto * nam = new HttpCache_NAM(parent);
    auto * ndc = new QNetworkDiskCache(parent);
    ndc->setCacheDirectory(QStandardPaths::writableLocation(QStandardPaths::CacheLocation));
    ndc->setMaximumCacheSize(20*1024*1024);
    nam->setCache(ndc);
    return nam;
}
