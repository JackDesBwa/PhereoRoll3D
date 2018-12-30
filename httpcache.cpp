#include "httpcache.h"

#include <QNetworkDiskCache>
#include <QNetworkReply>
#include <QStandardPaths>

QNetworkReply * HttpCache_NAM::createRequest(QNetworkAccessManager::Operation op, const QNetworkRequest &originalReq, QIODevice *outgoingData) {
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
