#include "httpcache.h"

#include <QNetworkDiskCache>
#include <QNetworkReply>
#include <QStandardPaths>

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

QNetworkReply * HttpCache_NAM::createRequest(QNetworkAccessManager::Operation op, const QNetworkRequest &originalReq, QIODevice *outgoingData) {
    if (originalReq.url().url() == "https://api.phereo.com/files/avatar.jpg")
        return new NetworkErrorReply(QNetworkReply::ContentNotFoundError, "User has not defined its avatar");

    auto req = originalReq;
    req.setAttribute(QNetworkRequest::CacheLoadControlAttribute, QNetworkRequest::PreferCache);
    req.setAttribute(QNetworkRequest::CacheSaveControlAttribute, true);
    req.setAttribute(QNetworkRequest::HttpPipeliningAllowedAttribute, true);
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
